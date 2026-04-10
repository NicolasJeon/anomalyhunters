import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report
from skl2onnx import to_onnx
import onnx
import onnxruntime as ort

SEED = 42
rng = np.random.default_rng(SEED)

# label: 0 = normal, 1 = warning, 2 = abnormal
#
# 입력: 단일 샘플 [temperature, power]  (FEATURE_SIZE = 2)
#
# 판단 기준:
#   normal   : 온도 28–45°C, 전력 = 온도 × 1.5 ± noise (비례 관계 유지)
#   warning  : 온도 정상 범위, 전력 비정상적으로 높음 (temp × 1.5 + 20–35 W)
#   abnormal : 고온 (>50°C),  또는 고온 + 전력 급증 (관계 붕괴)


def make_normal_sample():
    temp  = rng.uniform(28.0, 45.0)
    power = temp * 1.5 + rng.normal(0.0, 3.0)
    power = float(np.clip(power, 40.0, 80.0))
    return np.array([temp, power], dtype=np.float32)


def make_warning_sample():
    temp  = rng.uniform(28.0, 45.0)
    power = temp * 1.5 + rng.uniform(20.0, 35.0) + rng.normal(0.0, 2.0)
    power = float(np.clip(power, 40.0, 130.0))
    return np.array([temp, power], dtype=np.float32)


def make_abnormal_sample():
    abnormal_type = rng.integers(0, 2)
    if abnormal_type == 0:
        # A. 고온 이상
        temp  = rng.uniform(50.0, 70.0)
        power = temp * 1.5 + rng.normal(0.0, 3.0)
        power = float(np.clip(power, 40.0, 130.0))
    else:
        # B. 고온 + 전력 동시 급증 (관계 붕괴)
        temp  = rng.uniform(45.0, 65.0)
        power = temp * 1.5 + rng.uniform(35.0, 55.0) + rng.normal(0.0, 2.0)
        power = float(np.clip(power, 40.0, 130.0))
    return np.array([temp, power], dtype=np.float32)


def build_dataset(n_per_class=2000):
    X_list, y_list = [], []

    for _ in range(n_per_class):
        X_list.append(make_normal_sample())
        y_list.append(0)

    for _ in range(n_per_class):
        X_list.append(make_warning_sample())
        y_list.append(1)

    for _ in range(n_per_class):
        X_list.append(make_abnormal_sample())
        y_list.append(2)

    X = np.array(X_list, dtype=np.float32)
    y = np.array(y_list, dtype=np.int64)
    return X, y


def train_model():
    X, y = build_dataset()

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=SEED, stratify=y
    )

    model = RandomForestClassifier(
        n_estimators=100,
        max_depth=8,
        random_state=SEED
    )
    model.fit(X_train, y_train)

    y_pred = model.predict(X_test)
    print("Accuracy:", accuracy_score(y_test, y_pred))
    print(classification_report(y_test, y_pred, target_names=["normal", "warning", "abnormal"]))

    return model, X_test


def export_onnx(model, sample_input, model_path="equipment_anomaly_rf.onnx"):
    onx = to_onnx(model, sample_input.astype(np.float32), target_opset=15,
                  options={'zipmap': False})
    with open(model_path, "wb") as f:
        f.write(onx.SerializeToString())
    print(f"Saved: {model_path}")


def verify_onnx(model_path, X_test):
    onnx_model = onnx.load(model_path)
    onnx.checker.check_model(onnx_model)

    session = ort.InferenceSession(model_path)
    input_name = session.get_inputs()[0].name
    output_names = [o.name for o in session.get_outputs()]
    print("Input :", input_name, session.get_inputs()[0].shape)
    print("Outputs:", output_names)

    outputs = session.run(None, {input_name: X_test[:5].astype(np.float32)})
    for i, out in enumerate(outputs):
        print(f"output[{i}]:", out)


if __name__ == "__main__":
    model, X_test = train_model()
    export_onnx(model, X_test[:1])
    verify_onnx("equipment_anomaly_rf.onnx", X_test)
