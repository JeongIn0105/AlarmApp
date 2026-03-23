//
//  Alarm.swift
//  AlarmApp
//
//  Created by 이정인 on 3/23/26.
//

import Foundation

// MARK: - 알람 데이터 구현
struct Alarm: Codable, Equatable {
    let id: UUID
    var hour: Int
    var minute: Int
    var isAM: Bool
    var label: String
    var repeatDays: [Weekday]
    var soundName: String
    var isSnoozeEnabled: Bool
    var snoozeMinutes: Int
    var isEnabled: Bool
    
    // MARK: - 알람 생성 시 초기값 설정
    init(
        id: UUID = UUID(),                  // 알람 고유 식별자 (기본값 자동 생성)
        hour: Int,                          // 시간 (시)
        minute: Int,                        // 시간 (분)
        isAM: Bool,                         // 오전 / 오후 구분
        label: String = "알람",              // 알람 이름 (기본값: "알람")
        repeatDays: [Weekday] = [],         // 반복 요일 (기본값: 없음)
        soundName: String = "레이더",         // 알람 사운드 (기본값: 레이더)
        isSnoozeEnabled: Bool = true,       // 다시 알림 여부 (기본값: 켜짐)
        snoozeMinutes: Int = 7,             // 다시 알림 시간 (기본값: 7분)
        isEnabled: Bool = true              // 알람 활성화 여부 (기본값: ON)
    ) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.isAM = isAM
        self.label = label
        self.repeatDays = repeatDays
        self.soundName = soundName
        self.isSnoozeEnabled = isSnoozeEnabled
        self.snoozeMinutes = snoozeMinutes
        self.isEnabled = isEnabled
    }
    
    // MARK: - 알람 시간을 "시:분" 형식의 문자열로 변환
    var timeText: String {
        String(format: "%d:%02d", hour, minute)
    }
    
    // MARK: - 오전 / 오후 문자열 반환
    var meridiemText: String {
        isAM ? "오전" : "오후"
    }
    
    // MARK: - 반복 요일을 문자열로 변환
    var repeatText: String {
        if repeatDays.isEmpty {
            return "안 함"
        }
        
        return repeatDays.map { $0.koreanTitle }.joined(separator: ", ")
    }
}

// MARK: - 요일 데이터
enum Weekday: Int, Codable, CaseIterable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    // MARK: - 요일을 한글 문자열로 반환
    var koreanTitle: String {
        switch self {
        case .sunday: return "일"
        case .monday: return "월"
        case .tuesday: return "화"
        case .wednesday: return "수"
        case .thursday: return "목"
        case .friday: return "금"
        case .saturday: return "토"
        }
    }
}
