//
//  SceneDelegate.swift
//  AlarmApp
//

import UIKit
import UserNotifications
import RxRelay

final class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = MainTabBarViewController()
        self.window = window
        window.makeKeyAndVisible()
        
        // 🔥 이거 없으면 절대 안됨
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - 앱 켜져 있을 때 알림 도착
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("알림 도착:", notification.request.identifier)
        
        let alarms = AlarmViewModel.shared.alarms.value
        
        if let matchedAlarm = alarms.first(where: {
            notification.request.identifier.contains($0.id.uuidString)
        }) {
            print("매칭된 알람:", matchedAlarm.soundName)
            
            // 🔥 여기서 소리 재생됨
            AlarmViewModel.shared.triggerForegroundAlarm(matchedAlarm)
        } else {
            print("알람 매칭 실패")
        }
        
        // 배너 표시
        completionHandler([.banner, .list])
    }
    
    // MARK: - 알림 클릭했을 때
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let alarms = AlarmViewModel.shared.alarms.value
        
        if let matchedAlarm = alarms.first(where: {
            response.notification.request.identifier.contains($0.id.uuidString)
        }) {
            AlarmViewModel.shared.triggerForegroundAlarm(matchedAlarm)
        }
        
        completionHandler()
    }
}
