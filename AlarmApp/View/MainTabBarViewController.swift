//
//  MainTabBarViewController.swift
//  AlarmApp
//
//  Created by 이정인 on 3/20/26.
//

// MARK: - 하단 TabBar 구현(실행 화면)
import UIKit

final class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setupViewControllers()
        configureTabBarAppearance()
    }
    
    // MARK: - 탭바 외형 설정
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.shadowColor = .clear
        
        // 선택된 아이템 색상
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 255/255, green: 141/255, blue: 40/255, alpha: 1.0)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(red: 255/255, green: 141/255, blue: 40/255, alpha: 1.0)
        ]
        
        // 선택되지 않은 아이템 색상
        appearance.stackedLayoutAppearance.normal.iconColor = .white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.backgroundColor = .black
        tabBar.barTintColor = .black
        tabBar.isTranslucent = false
        tabBar.tintColor = UIColor(red: 255/255, green: 141/255, blue: 40/255, alpha: 1.0)
        tabBar.unselectedItemTintColor = .white
        tabBar.layer.masksToBounds = true
    }

    private func setupViewControllers() {

        // 알람 탭
        let alarm = AlarmViewController()
        let alarmNav = UINavigationController(rootViewController: alarm)
        alarmNav.tabBarItem = UITabBarItem(
            title: "알람",
            image: UIImage(systemName: "alarm.fill"),
            tag: 0
        )

        // 스톱워치 탭
        let stopwatch = StopwatchViewController()
        let stopWatchNav = UINavigationController(rootViewController: stopwatch)
        stopWatchNav.tabBarItem = UITabBarItem(
            title: "스톱워치",
            image: UIImage(systemName: "stopwatch.fill"),
            tag: 1
        )

        // 타이머 탭
        let timer = TimerViewController()
        let timerNav = UINavigationController(rootViewController: timer)
        timerNav.tabBarItem = UITabBarItem(
            title: "타이머",
            image: UIImage(systemName: "timer"),
            tag: 2
        )

        viewControllers = [alarmNav, stopWatchNav, timerNav]
    }
}
