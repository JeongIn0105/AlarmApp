//
//  EditViewController.swift
//  AlarmApp
//
//  Created by 이정인 on 3/20/26.
//

import UIKit

final class EditViewController: UIViewController {
    
    // MARK: - 생명 주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
    }
    
    // MARK: 네비게이션 바 다시 보이게 구현
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - 편집 화면 UI 구성
    private func configureUI() {
        
        view.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        
        
    }
}
