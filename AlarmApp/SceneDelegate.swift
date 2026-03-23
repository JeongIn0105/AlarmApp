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
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    // 앱이 켜져 있을 때도 알림 표시
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
    
    // 알림을 눌렀을 때 foreground 알람 사운드 재생
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
