#pragma once

#include <QString>
#include <QVariantList>

// SQLite 기반 이벤트 로그 매니저 (싱글톤)
// QSqlDatabase 기본 커넥션을 사용하므로 단일 스레드에서만 호출할 것
class DatabaseManager
{
public:
    static DatabaseManager& instance();

    // 앱 시작 시 1회 호출 — DB 파일 생성 및 테이블 초기화
    bool init(const QString& path = "facility.db");

    // ── 장비 목록 영구 저장 ────────────────────────────────────────────────
    // 저장된 장비 목록을 order_index 순으로 반환
    QVariantList loadEquipment() const;
    // 장비 추가 (order_index = 기존 최대 + 1)
    void saveNewEquipment(const QString& id, const QString& name, const QString& imageSource);
    // 장비 삭제
    void deleteEquipment(const QString& id);
    // 장비 정보 수정
    void updateEquipment(const QString& id, const QString& name, const QString& imageSource);

    // ── 상태 이벤트 로그 ───────────────────────────────────────────────────
    QVariantList queryStateEvents(const QString& equipmentId, int limit = 50) const;
    void clearEquipmentEvents(const QString& equipmentId);
    void insertStateEvent(
        const QString& equipmentId,
        const QString& equipmentName,
        const QString& state,
        const QString& controlStatus,
        float temperature,
        float power,
        qint64 timestampMs   // original log timestamp
    );

private:
    DatabaseManager() = default;
    bool initialized_ = false;
};
