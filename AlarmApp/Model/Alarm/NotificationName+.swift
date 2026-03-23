//
//  NotificationName+.swift
//  AlarmApp
//
//  Created by 이정인 on 3/23/26.
//

import Foundation

// MARK: - 알람 데이터 변경 시 화면 갱신에 사용할 Notification Name 정의
extension Notification.Name {
    static let alarmDataDidChange = Notification.Name("alarmDataDidChange")
}
