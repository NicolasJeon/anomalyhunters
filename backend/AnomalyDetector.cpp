#include "AnomalyDetector.h"

#include <onnxruntime_cxx_api.h>

#include <array>
#include <stdexcept>
#ifdef _WIN32
#  include <locale>
#  include <codecvt>
#endif

// ── ORT 내부 객체 묶음 ────────────────────────────────────────────────────
struct AnomalyDetector::OrtImpl {
    Ort::Env            env{ORT_LOGGING_LEVEL_WARNING, "AnomalyDetector"};
    Ort::SessionOptions opts;
    Ort::Session        session;

    explicit OrtImpl(const std::string& modelPath)
#ifdef _WIN32
        : session(env, toOrtPath(modelPath).c_str(), opts)
#else
        : session(env, modelPath.c_str(), opts)
#endif
    {}

#ifdef _WIN32
    static std::wstring toOrtPath(const std::string& path) {
        std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> conv;
        return conv.from_bytes(path);
    }
#endif
};

// ── 생성자 / 소멸자 ───────────────────────────────────────────────────────
AnomalyDetector::AnomalyDetector(const std::string& modelPath)
    : ort_(new OrtImpl(modelPath))
{}

AnomalyDetector::~AnomalyDetector()
{
    delete ort_;
}


// ── predict ───────────────────────────────────────────────────────────────
AnomalyDetector::Result AnomalyDetector::predict(float temperature, float power)
{
    std::array<float, FEATURE_SIZE> features = { temperature, power };

    // ── ONNX 추론 ─────────────────────────────────────────────────────────
    Ort::AllocatorWithDefaultOptions allocator;

    std::vector<int64_t> inputShape = {1, FEATURE_SIZE};
    Ort::MemoryInfo memInfo = Ort::MemoryInfo::CreateCpu(
        OrtArenaAllocator, OrtMemTypeDefault);

    Ort::Value inputTensor = Ort::Value::CreateTensor<float>(
        memInfo,
        features.data(), features.size(),
        inputShape.data(), inputShape.size());

    auto inputNameAlloc = ort_->session.GetInputNameAllocated(0, allocator);
    auto outLabel       = ort_->session.GetOutputNameAllocated(0, allocator);
    auto outProb        = ort_->session.GetOutputNameAllocated(1, allocator);

    const char* inputNames[]  = { inputNameAlloc.get() };
    const char* outputNames[] = { outLabel.get(), outProb.get() };

    auto outputs = ort_->session.Run(
        Ort::RunOptions{nullptr},
        inputNames,  &inputTensor, 1,
        outputNames, 2);

    // output[0]: label (int64)  — 0=normal, 1=warning, 2=abnormal
    int64_t label = outputs[0].GetTensorData<int64_t>()[0];

    // output[1]: probabilities tensor (1, 3)  — [P(normal), P(warning), P(abnormal)]
    const float* probData = outputs[1].GetTensorData<float>();

    Result res;
    res.label         = static_cast<int>(label);
    res.prob_normal   = probData[0];
    res.prob_warning  = probData[1];
    res.prob_abnormal = probData[2];
    return res;
}
