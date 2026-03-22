# Equipment Anomaly Detection Demo — 구현 리포트

## 1. 프로젝트 개요

설비 데이터(온도/전력) 스트림에서 이상 패턴을 실시간 감지하는 Qt/QML 데모 앱.

- Python으로 학습 데이터 생성 + 모델 훈련 + ONNX export
- C++/Qt에서 동일한 feature extraction 구현 후 ONNX Runtime으로 추론
- QML UI에서 500 ms 주기로 결과를 시각화
- 다수 장비(N대)를 DeviceRepository 중심 구조로 관리

---

## 2. 기술 스택

| 항목 | 내용 |
|------|------|
| 언어 | Python 3, C++17 |
| ML 프레임워크 | scikit-learn (RandomForestClassifier) |
| ONNX 변환 | skl2onnx |
| 추론 엔진 | ONNX Runtime 1.24.4 (Homebrew) |
| UI 프레임워크 | Qt 6.8 / QML |
| 빌드 시스템 | CMake 3.16+ |
| 플랫폼 | macOS (Apple Silicon) |

---

## 3. Python 파이프라인 (`onnx/generate_data.py`)

### 3-1. 데이터 구조

- 입력: 길이 10의 (temperature, power) 시퀀스
- 정상 생성:
  - temperature: 30–35 °C 시작, 랜덤워크, [28, 45] 클리핑
  - power = temperature × 1.5 + N(0, 2), [40, 80] 클리핑

### 3-2. 이상 패턴 3가지

| 타입 | 설명 | 변조 방법 |
|------|------|-----------|
| A. 고온 이상 | 시퀀스 후반부 온도 급상승 | `temp[start:] += U(18, 25)` |
| B. 전력 급증 | 특정 시점 전력 스파이크 | `power[idx] += U(25, 40)` |
| C. 관계 붕괴 | 온도 보통, 전력만 과도 | `power[start:] += U(30, 40)` |

### 3-3. Feature Engineering (11개)

```
[0]  temp.mean()
[1]  temp.min()
[2]  temp.max()
[3]  temp[-1]           (최신값)
[4]  power.mean()
[5]  power.min()
[6]  power.max()
[7]  power[-1]
[8]  max(|Δtemp|)       (최대 변화량)
[9]  max(|Δpower|)
[10] Pearson r(temp, power)
```

### 3-4. 모델 훈련 결과

```
RandomForestClassifier(n_estimators=100, max_depth=6, random_state=42)
Train/Test = 80/20, stratify=y
Accuracy: 1.00  (train 1600 / test 400)
```

### 3-5. ONNX Export

```python
to_onnx(model, X[:1].astype(np.float32),
        target_opset=15,
        options={'zipmap': False})   # ← probability를 tensor로 출력
```

- Input : `X`  shape `(1, 11)`  dtype float32
- Output[0]: `label`         shape `(1,)`    dtype int64
- Output[1]: `probabilities` shape `(1, 2)`  dtype float32  [P(normal), P(abnormal)]

---

## 4. C++ 아키텍처

### 4-1. 폴더 구조

```
QtFacility/
├── backend/
│   ├── Device.h                        ← 데이터 모델 struct 3종
│   ├── AnomalyDetector.h / .cpp        ← 슬라이딩 윈도우 + ORT 추론
│   ├── DeviceTimeSeriesSimulator.h / .cpp  ← 순수 C++ 시뮬레이터
│   └── DeviceRepository.h / .cpp       ← QObject 핵심 백엔드
├── ui/
│   └── Main.qml                        ← 멀티 디바이스 UI
├── main.cpp                            ← 앱 진입점
├── CMakeLists.txt
└── equipment_anomaly_rf.onnx           ← Qt 리소스로 앱 번들 embed
```

### 4-2. 데이터 모델 (`backend/Device.h`)

```cpp
struct TimeSeriesSample {
    qint64 timestampMs; float temperature; float power;
    int label; float probAbnormal;   // 추론 결과 함께 저장
};

struct InferenceState {
    int label = -1;  float probNormal; float probAbnormal;
    QString statusText() const;   // "Buffering..." | "Normal" | "ABNORMAL"
};

struct Device {
    QString id, name, type;
    QString healthStatus;    // normal | warning | anomaly
    QString controlStatus;   // stopped | running
    QString imageSource;
};
```

### 4-3. AnomalyDetector (`backend/AnomalyDetector.h/.cpp`)

```cpp
class AnomalyDetector {
    static constexpr int SEQ_LEN      = 10;
    static constexpr int FEATURE_SIZE = 11;

    struct Result { int label=-1; float prob_normal; float prob_abnormal; };

    Result push(float temperature, float power);
    // 내부: std::deque 슬라이딩 윈도우
    //       extractFeatures() → Python과 동일한 11개 계산
    //       ORT Session::Run() → label + float[2] probabilities
};
```

**probability 파싱 (zipmap=False 덕분에 단순):**
```cpp
const float* p = outputs[1].GetTensorData<float>();
// p[0] = P(normal),  p[1] = P(abnormal)
```

### 4-4. DeviceTimeSeriesSimulator (`backend/DeviceTimeSeriesSimulator.h/.cpp`)

순수 C++ 유틸. Qt 의존성 없음.

```cpp
class DeviceTimeSeriesSimulator {
    struct Sample { float temperature; float power; };
    Sample next();   // 매 호출마다 1 tick 진행
};
```

- 각 인스턴스는 `std::random_device`로 독립적인 RNG 시드 초기화
- 정상 25 tick → 이상 5–10 tick 반복 (랜덤 편차)
- 이상 타입 A/B/C 중 랜덤 선택

### 4-5. DeviceRepository (`backend/DeviceRepository.h/.cpp`)

앱의 핵심 백엔드. QML에 `repository` context property로 노출.

**Q_PROPERTY**

| 프로퍼티 | 타입 | 설명 |
|---------|------|------|
| `devices` | `QVariantList` | 전체 장비 목록 |
| `selectedDeviceId` | `QString` | 선택된 장비 ID (읽기/쓰기) |
| `selectedDevice` | `QVariantMap` | 선택 장비 상세 |
| `selectedTimeSeries` | `QVariantList` | 최근 20개 샘플 |
| `selectedInference` | `QVariantMap` | 선택 장비 추론 상태 |

**Q_INVOKABLE API**

```cpp
void addDevice(QString name, QString type, QString imageSource);
void removeDevice(QString deviceId);
void updateDevice(QString deviceId, QString name, QString type, QString imageSource);
void startDevice(QString deviceId);
void stopDevice(QString deviceId);
void startSimulation();
void stopSimulation();
```

**tick() 로직 (500 ms)**

```
for each device (controlStatus == "running"):
    sample  = simulator.next()
    result  = detector.push(sample.temperature, sample.power)
    update  inferenceState
    update  device.healthStatus (probAbnormal 기준)
    append  to timeSeriesMap (최대 100개 보관)

emit devicesChanged()
if selectedDevice is running:
    emit selectedDeviceChanged / selectedTimeSeriesChanged / selectedInferenceChanged
```

**healthStatus 규칙**

```
probAbnormal < 0.4          → "normal"
0.4 ≤ probAbnormal < 0.7   → "warning"
probAbnormal ≥ 0.7          → "anomaly"
```

**내부 구조**

```cpp
struct DeviceEntry {
    Device                    device;
    DeviceTimeSeriesSimulator simulator;
    AnomalyDetector*          detector;   // 장비당 독립 ORT 세션
    InferenceState            inference;
    QVector<TimeSeriesSample> series;     // 최대 100개
};
QHash<QString, DeviceEntry*> entries_;   // raw ptr, qDeleteAll on dtor
QStringList                  deviceOrder_;  // 안정적 순서 보장
```

### 4-6. main.cpp — 모델 배포 전략

- `.onnx`를 `qt_add_resources`로 앱 번들에 embed
- 실행 시 `:/models/equipment_anomaly_rf.onnx` → `$TMPDIR`로 추출
  (ONNX Runtime은 파일 경로로 세션 생성하므로 임시 파일 필요)
- 매 실행마다 덮어씀 → 모델 갱신 시 캐시 문제 없음

```cpp
engine.rootContext()->setContextProperty("repository", &repository);
```

---

## 5. QML UI (`ui/Main.qml`)

### 5-1. 레이아웃

```
Window 840 × 640
└── Row
    ├── 좌측 패널 (220px) — 디바이스 목록
    │   ├── 헤더 "Devices" + [+] 추가 버튼
    │   └── ListView (repository.devices)
    │       └── 아이템: 상태원 · 이름 · 타입 · healthStatus
    │                   [Start/Stop] [×]
    └── 우측 패널 (620px) — 선택 장비 상세
        ├── 헤더: 장비명 · 타입 · [Start/Stop]
        ├── 상태 배너 (색상 애니메이션 250 ms)
        ├── 값 그리드: T / P / P(Normal) / P(Abnormal)
        ├── P(Abnormal) 게이지
        ├── Temperature 히스토리 bars (Repeater, 최근 20개)
        ├── Power 히스토리 bars
        └── 로그 ListView (BottomToTop)
```

### 5-2. 상태 색상

| 상태 | 목록 원 | 배너 배경 |
|------|---------|----------|
| normal | `#22aa66` 녹색 | `#1a7a4a` 녹색 |
| warning | `#e8a030` 주황 | — |
| anomaly | `#cc3344` 빨강 | `#9b2335` 빨강 |
| buffering | `#555577` 회색 | `#444466` 회색 |

### 5-3. QML 바인딩 패턴

```qml
property var selDev: repository.selectedDevice   // QVariantMap alias
property var selInf: repository.selectedInference

// 안전한 null 접근 (선택 없을 때 empty map 반환)
text: root.selDev["name"] ?? ""
width: parent.width * (root.selInf["probAbnormal"] ?? 0)
```

---

## 6. 실행 결과 확인

```
# 처음 9 tick — 버퍼 채우는 중 (label: -1)
T: 32.6  P: 51.3  label: -1

# 10번째 tick — 첫 추론 (정상)
T: 32.8  P: 50.9  label: 0  p_abn: 0.006

# 25 tick 이후 — 이상 주입 (고온 Type A)
T: 54.2  P: 52.8  label: 1  p_abn: 0.990
T: 65.0  P: 66.8  label: 1  p_abn: 0.980

# 33 tick 이후 — 정상 복귀
T: 33.4  P: 50.1  label: 0  p_abn: 0.008
```

---

## 7. 빌드 방법

```bash
# 의존성 설치
brew install onnxruntime

# Python 모델 생성 (초기 1회)
cd onnx
source ~/onnx/bin/activate
python generate_data.py
cp equipment_anomaly_rf.onnx ../

# C++ 빌드
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
cmake --build . --parallel

# 실행
Debug/appQtFacility.app/Contents/MacOS/appQtFacility
```

---

## 8. 현재 상태 / 다음 단계 후보

### 완료
- [x] Python 데이터 생성 파이프라인
- [x] Feature extraction (Python / C++ 동일)
- [x] RandomForest 훈련 + ONNX export (zipmap=False)
- [x] C++ AnomalyDetector (슬라이딩 윈도우 + ORT 추론)
- [x] DeviceTimeSeriesSimulator (순수 C++, 장비별 독립 RNG)
- [x] DeviceRepository (QObject, 다장비 관리, CRUD + Start/Stop)
- [x] QML 멀티 디바이스 UI (리스트 + 상세 + 히스토리 + 로그)
- [x] backend/ / ui/ 폴더 분리

### 다음 단계 후보
- [ ] 실제 장비 데이터 연결 (Serial / MQTT / Modbus)
- [ ] 모델 교체 없이 threshold 파라미터 조정 UI
- [ ] 이상 감지 이벤트 로그 저장 (CSV / SQLite)
- [ ] Qt Charts / QtGraphs 기반 실시간 라인 차트
- [ ] 장비 편집 다이얼로그 (updateDevice UI)

---

## 9. 주요 설계 결정 사항

| 결정 | 이유 |
|------|------|
| RandomForest + ONNX (not DNN) | 소규모 구조적 feature에서 충분한 성능, ONNX 변환 단순 |
| zipmap=False | C++ probability 파싱을 `float*[0,1]`로 단순화 |
| Homebrew ORT | 세미나 환경에서 설치 1줄로 완결 |
| qt_add_resources embed | 배포 시 모델 파일 별도 관리 불필요 |
| DeviceRepository + QVariantList | QML Repeater/ListView 직접 바인딩, 추가 모델 클래스 불필요 |
| AnomalyDetector Qt 비의존 | 순수 C++ → 재사용성 확보, 단위 테스트 용이 |
| DeviceTimeSeriesSimulator Qt 비의존 | 장비별 독립 인스턴스, 랜덤 시드 분리 |
| QHash<QString, DeviceEntry*> raw ptr | Qt 6.8에서 QHash + unique_ptr 복사 문제 회피, qDeleteAll로 정리 |
| backend/ / ui/ 폴더 분리 | C++ 로직과 QML 뷰의 명확한 경계 |
