#include "AnomalyDetector.h"

#include <onnxruntime_cxx_api.h>

#include <algorithm>
#include <cmath>
#include <numeric>
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

// ── push ──────────────────────────────────────────────────────────────────
AnomalyDetector::Result AnomalyDetector::push(float temperature, float power)
{
    buffer_.push_back({temperature, power});
    if (static_cast<int>(buffer_.size()) > SEQ_LEN)
        buffer_.pop_front();

    if (static_cast<int>(buffer_.size()) < SEQ_LEN)
        return {};   // label == -1

    // ── feature extraction ────────────────────────────────────────────────
    auto features = extractFeatures();

    // ── ONNX 추론 ─────────────────────────────────────────────────────────
    Ort::AllocatorWithDefaultOptions allocator;

    // input
    std::vector<int64_t> inputShape = {1, FEATURE_SIZE};
    Ort::MemoryInfo memInfo = Ort::MemoryInfo::CreateCpu(
        OrtArenaAllocator, OrtMemTypeDefault);

    Ort::Value inputTensor = Ort::Value::CreateTensor<float>(
        memInfo,
        features.data(), features.size(),
        inputShape.data(), inputShape.size());

    // input / output 이름
    auto inputNameAlloc  = ort_->session.GetInputNameAllocated(0, allocator);
    auto outLabel        = ort_->session.GetOutputNameAllocated(0, allocator);
    auto outProb         = ort_->session.GetOutputNameAllocated(1, allocator);

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

// ── extractFeatures ───────────────────────────────────────────────────────
// Python extract_features() 와 완전 동일한 순서
std::array<float, AnomalyDetector::FEATURE_SIZE>
AnomalyDetector::extractFeatures() const
{
    const int N = static_cast<int>(buffer_.size());

    std::vector<float> temp(N), power(N);
    for (int i = 0; i < N; ++i) {
        temp[i]  = buffer_[i][0];
        power[i] = buffer_[i][1];
    }

    // ── 통계 헬퍼 ──────────────────────────────────────────────────────────
    auto mean = [&](const std::vector<float>& v) {
        return std::accumulate(v.begin(), v.end(), 0.0f) / v.size();
    };
    auto minv = [&](const std::vector<float>& v) {
        return *std::min_element(v.begin(), v.end());
    };
    auto maxv = [&](const std::vector<float>& v) {
        return *std::max_element(v.begin(), v.end());
    };
    auto diffMaxAbs = [&](const std::vector<float>& v) {
        float m = 0.0f;
        for (int i = 1; i < static_cast<int>(v.size()); ++i)
            m = std::max(m, std::abs(v[i] - v[i-1]));
        return m;
    };

    float tMean = mean(temp),  pMean = mean(power);
    float tStd  = 0.0f,        pStd  = 0.0f;
    for (int i = 0; i < N; ++i) {
        tStd += (temp[i]  - tMean) * (temp[i]  - tMean);
        pStd += (power[i] - pMean) * (power[i] - pMean);
    }
    tStd = std::sqrt(tStd / N);
    pStd = std::sqrt(pStd / N);

    float corr = 0.0f;
    if (tStd > 1e-6f && pStd > 1e-6f) {
        float cov = 0.0f;
        for (int i = 0; i < N; ++i)
            cov += (temp[i] - tMean) * (power[i] - pMean);
        corr = (cov / N) / (tStd * pStd);
    }

    return {
        tMean,
        minv(temp),
        maxv(temp),
        temp.back(),
        pMean,
        minv(power),
        maxv(power),
        power.back(),
        diffMaxAbs(temp),
        diffMaxAbs(power),
        corr
    };
}
