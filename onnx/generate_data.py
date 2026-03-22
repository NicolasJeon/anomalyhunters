import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report
from skl2onnx import to_onnx
import onnx
import onnxruntime as ort

SEED = 42
rng = np.random.default_rng(SEED)

SEQ_LEN = 10

def make_normal_sequence(seq_len=SEQ_LEN):
    temp = [rng.uniform(30.0, 35.0)]

    for _ in range(seq_len - 1):
        next_temp = temp[-1] + rng.normal(0.0, 1.0)
        next_temp = np.clip(next_temp, 28.0, 45.0)
        temp.append(next_temp)

    temp = np.array(temp, dtype=np.float32)

    power = temp * 1.5 + rng.normal(0.0, 2.0, size=seq_len)
    power = np.clip(power, 40.0, 80.0).astype(np.float32)

    return np.stack([temp, power], axis=1)


def inject_abnormal(seq):
    seq = seq.copy()
    abnormal_type = rng.integers(0, 3)

    if abnormal_type == 0:
        # A. 고온 이상
        start = rng.integers(seq.shape[0] // 2, seq.shape[0])
        seq[start:, 0] += rng.uniform(18.0, 25.0)

    elif abnormal_type == 1:
        # B. 전력 급증 이상
        idx = rng.integers(1, seq.shape[0])
        seq[idx, 1] += rng.uniform(25.0, 40.0)

    else:
        # C. 관계 붕괴 이상
        start = rng.integers(seq.shape[0] // 2, seq.shape[0])
        seq[start:, 1] += rng.uniform(30.0, 40.0)

    return seq.astype(np.float32)


def extract_features(seq):
    temp = seq[:, 0]
    power = seq[:, 1]

    temp_diff = np.diff(temp)
    power_diff = np.diff(power)

    corr = 0.0
    if temp.std() > 1e-6 and power.std() > 1e-6:
        corr = np.corrcoef(temp, power)[0, 1]

    features = np.array([
        temp.mean(),
        temp.min(),
        temp.max(),
        temp[-1],
        power.mean(),
        power.min(),
        power.max(),
        power[-1],
        np.abs(temp_diff).max() if len(temp_diff) > 0 else 0.0,
        np.abs(power_diff).max() if len(power_diff) > 0 else 0.0,
        corr
    ], dtype=np.float32)

    return features


def build_dataset(n_normal=1000, n_abnormal=1000):
    normal_samples = []
    abnormal_samples = []

    for _ in range(n_normal):
        seq = make_normal_sequence()
        normal_samples.append(extract_features(seq))

    for _ in range(n_abnormal):
        seq = make_normal_sequence()
        seq = inject_abnormal(seq)
        abnormal_samples.append(extract_features(seq))

    X_normal = np.array(normal_samples, dtype=np.float32)
    X_abnormal = np.array(abnormal_samples, dtype=np.float32)

    y_normal = np.zeros(len(X_normal), dtype=np.int64)
    y_abnormal = np.ones(len(X_abnormal), dtype=np.int64)

    X = np.concatenate([X_normal, X_abnormal], axis=0)
    y = np.concatenate([y_normal, y_abnormal], axis=0)

    return X, y


def train_model():
    X, y = build_dataset()

    X_train, X_test, y_train, y_test = train_test_split(
        X, y,
        test_size=0.2,
        random_state=SEED,
        stratify=y
    )

    model = RandomForestClassifier(
        n_estimators=100,
        max_depth=6,
        random_state=SEED
    )
    model.fit(X_train, y_train)

    y_pred = model.predict(X_test)

    print("Accuracy:", accuracy_score(y_test, y_pred))
    print(classification_report(y_test, y_pred))

    return model, X_test


def export_onnx(model, sample_input, model_path="equipment_anomaly_rf.onnx"):
    onx = to_onnx(model, sample_input.astype(np.float32), target_opset=15,
                  options={'zipmap': False})

    with open(model_path, "wb") as f:
        f.write(onx.SerializeToString())

    print(f"Saved ONNX model: {model_path}")


def verify_onnx(model_path, X_test):
    onnx_model = onnx.load(model_path)
    onnx.checker.check_model(onnx_model)

    session = ort.InferenceSession(model_path)

    input_name = session.get_inputs()[0].name
    output_names = [o.name for o in session.get_outputs()]

    print("Input name:", input_name)
    print("Output names:", output_names)

    outputs = session.run(None, {input_name: X_test[:5].astype(np.float32)})

    for i, out in enumerate(outputs):
        print(f"output[{i}]:")
        print(out)


if __name__ == "__main__":
    model, X_test = train_model()
    export_onnx(model, X_test[:1])
    verify_onnx("equipment_anomaly_rf.onnx", X_test)