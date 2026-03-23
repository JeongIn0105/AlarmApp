//
//  AlarmViewModel.swift
//  AlarmApp
//
//  Created by 이정인 on 3/20/26.
//

import Foundation
import UserNotifications
import RxSwift
import RxCocoa

// MARK: - 알람 ViewModel 구현
final class AlarmViewModel {
    
    static let shared = AlarmViewModel()
    
    private let storageKey = "saved_alarms"
    private let audioEngine = AlarmAudioEngine()
    
    private var foregroundAlarm: Alarm?
    
    let alarms = BehaviorRelay<[Alarm]>(value: [])
    
    private init() {
        loadAlarms()
        requestNotificationPermission()
        
        do {
            try audioEngine.setupAudioSession()
        } catch {
            print("AudioSession 설정 오류: \(error)")
        }
    }
    
    // MARK: - 알림 권한 요청
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    // MARK: - 저장된 알람 불러오기
    func loadAlarms() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Alarm].self, from: data)
        else {
            alarms.accept([])
            return
        }
        
        let sortedAlarms = decoded.sorted {
            let lhs = ($0.isAM ? 0 : 12) + ($0.hour % 12)
            let rhs = ($1.isAM ? 0 : 12) + ($1.hour % 12)
            
            if lhs == rhs {
                return $0.minute < $1.minute
            }
            return lhs < rhs
        }
        
        alarms.accept(sortedAlarms)
    }
    
    // MARK: - 알람 저장
    func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(alarms.value) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    // MARK: - 알람 추가
    func addAlarm(_ alarm: Alarm) {
        var currentAlarms = alarms.value
        currentAlarms.append(alarm)
        alarms.accept(currentAlarms)
        loadAndReschedule()
    }
    
    // MARK: - 알람 수정
    func updateAlarm(_ alarm: Alarm) {
        var currentAlarms = alarms.value
        
        guard let index = currentAlarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        
        currentAlarms[index] = alarm
        alarms.accept(currentAlarms)
        loadAndReschedule()
    }
    
    // MARK: - 알람 삭제
    func deleteAlarm(id: UUID) {
        let filteredAlarms = alarms.value.filter { $0.id != id }
        alarms.accept(filteredAlarms)
        cancelNotification(for: id)
        cancelSnoozeNotification(for: id)
        loadAndReschedule()
    }
    
    // MARK: - 알람 활성화 / 비활성화
    func toggleAlarm(id: UUID, isOn: Bool) {
        var currentAlarms = alarms.value
        
        guard let index = currentAlarms.firstIndex(where: { $0.id == id }) else { return }
        
        currentAlarms[index].isEnabled = isOn
        alarms.accept(currentAlarms)
        saveAlarms()
        
        if isOn {
            scheduleNotification(for: currentAlarms[index])
        } else {
            cancelNotification(for: id)
            cancelSnoozeNotification(for: id)
        }
    }
    
    // MARK: - 저장 후 다시 로드하고 알림 재등록
    private func loadAndReschedule() {
        saveAlarms()
        loadAlarms()
        rescheduleAllNotifications()
        NotificationCenter.default.post(name: .alarmDataDidChange, object: nil)
    }
    
    // MARK: - 모든 알림 다시 예약
    private func rescheduleAllNotifications() {
        for alarm in alarms.value {
            cancelNotification(for: alarm.id)
            
            if alarm.isEnabled {
                scheduleNotification(for: alarm)
            }
        }
    }
    
    // MARK: - 알람 예약
    private func scheduleNotification(for alarm: Alarm) {
        if alarm.repeatDays.isEmpty {
            scheduleOneTimeNotification(for: alarm)
        } else {
            scheduleRepeatingNotification(for: alarm)
        }
    }
    
    // MARK: - 반복 없는 알람 예약
    private func scheduleOneTimeNotification(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = alarm.label
        content.body = "\(alarm.meridiemText) \(alarm.timeText) 알람 시간입니다."
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alarm-clock-short"))
        
        let calendar = Calendar.current
        let now = Date()
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = converted24Hour(from: alarm.hour, isAM: alarm.isAM)
        dateComponents.minute = alarm.minute
        dateComponents.second = 0
        
        guard var triggerDate = calendar.date(from: dateComponents) else { return }
        
        if triggerDate <= now {
            triggerDate = calendar.date(byAdding: .day, value: 1, to: triggerDate) ?? triggerDate
        }
        
        let finalDateComponents = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: triggerDate
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: finalDateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: alarm.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - 반복 알람 예약
    private func scheduleRepeatingNotification(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = alarm.label
        content.body = "\(alarm.meridiemText) \(alarm.timeText) 알람 시간입니다."
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alarm-clock-short"))
        
        for day in alarm.repeatDays {
            var dateComponents = DateComponents()
            dateComponents.weekday = day.rawValue
            dateComponents.hour = converted24Hour(from: alarm.hour, isAM: alarm.isAM)
            dateComponents.minute = alarm.minute
            dateComponents.second = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: "\(alarm.id.uuidString)_\(day.rawValue)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    // MARK: - 앱이 켜져 있을 때 알람 사운드 반복 재생
    func triggerForegroundAlarm(_ alarm: Alarm) {
        foregroundAlarm = alarm
        let preset = soundPreset(for: alarm.soundName)
        audioEngine.startRepeating(preset: preset)
    }
    
    // MARK: - 앱이 켜져 있을 때 알람 사운드 중지
    func stopForegroundAlarm() {
        foregroundAlarm = nil
        audioEngine.stopRepeating()
    }
    
    // MARK: - 다시 알림 예약
    func snoozeForegroundAlarm() {
        guard let alarm = foregroundAlarm, alarm.isSnoozeEnabled else { return }
        
        stopForegroundAlarm()
        
        let content = UNMutableNotificationContent()
        content.title = alarm.label
        content.body = "\(alarm.snoozeMinutes)분 뒤 다시 알림입니다."
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alarm-clock-short"))
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(alarm.snoozeMinutes * 60),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "\(alarm.id.uuidString)_snooze",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - 다시 알림 취소
    private func cancelSnoozeNotification(for id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["\(id.uuidString)_snooze"]
        )
    }
    
    // MARK: - 기존 알림 취소
    private func cancelNotification(for id: UUID) {
        let identifiers = Weekday.allCases.map { "\(id.uuidString)_\($0.rawValue)" } + [id.uuidString]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // MARK: - 사운드 이름을 프리셋으로 변환
    private func soundPreset(for soundName: String) -> AlarmSoundPreset {
        switch soundName {
        case "오프닝":
            return .opening
        case "차임":
            return .chime
        case "디지털":
            return .digital
        case "클래식":
            return .classic
        case "레이더":
            return .radar
        default:
            return .radar
        }
    }
    
    // MARK: - 12시간 형식을 24시간 형식으로 변환
    private func converted24Hour(from hour: Int, isAM: Bool) -> Int {
        if isAM {
            return hour == 12 ? 0 : hour
        } else {
            return hour == 12 ? 12 : hour + 12
        }
    }
}
