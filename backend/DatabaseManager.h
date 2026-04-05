#pragma once

#include <QString>

// SQLite 기반 이벤트 로그 매니저 (싱글톤)
// QSqlDatabase 기본 커넥션을 사용하므로 단일 스레드에서만 호출할 것
class DatabaseManager
{
public:
    static DatabaseManager& instance();

    // 앱 시작 시 1회 호출 — DB 파일 생성 및 테이블 초기화
    bool init(const QString& path = "facility.db");

    // 장비 상태 변화 이벤트를 기록
    void insertStateEvent(
        const QString& deviceId,
        const QString& deviceName,
        const QString& healthStatus,
        const QString& controlStatus,
        float temperature, float power,
        int   label,
        float probNormal, float probWarning, float probAbnormal
    );

private:
    DatabaseManager() = default;
    bool initialized_ = false;
};
