//
//  AlarmViewController.swift
//  AlarmApp
//
//  Created by 이정인 on 3/20/26.
//

import UIKit
import SnapKit
import Then

// MARK: - 알람 페이지 구현
final class AlarmViewController: UIViewController {
    
    // MARK: - UI 설정
    // "편집" 버튼
    private let editButton = UIButton().then {
        $0.setTitle("편집", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(red: 255/255, green: 94/255, blue: 0/255, alpha: 1.0)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 28)
        $0.layer.cornerRadius = 30
    }
    
    // "+" 버튼
    private let plusButton = UIButton().then {
        $0.setTitle("+", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(red: 255/255, green: 94/255, blue: 0/255, alpha: 1)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 28)
        $0.layer.cornerRadius = 30
    }
    
    // "정인이네 알람" 라벨
    private let alarmLabel = UILabel().then {
        $0.text = "정인이네 알람"
        $0.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        $0.font = .boldSystemFont(ofSize: 40)
    }
    
    // "라인" 뷰
    private let underlineView = UIView().then {
        $0.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    }
    
    // "기타" 라벨
    private let etcLabel = UILabel().then {
        $0.text = "기타"
        $0.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        $0.font = .boldSystemFont(ofSize: 32)
    }
    
    // MARK: - 생명 주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
    }
    
    // MARK: - 네비게이션 바 숨기기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - 알람 UI 구성
    private func configureUI() {
        
        [
            editButton,
            plusButton,
            alarmLabel,
            underlineView,
            etcLabel
        ].forEach { view.addSubview($0) }
        
        // MARK:  제약 조건 설정
        // "편집" 버튼의 제약 조건
        editButton.snp.makeConstraints {
            $0.width.equalTo(90)
            $0.height.equalTo(60)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.leading.equalToSuperview().offset(10)
        }
        
        // "+" 버튼의 제약 조건
        plusButton.snp.makeConstraints {
            $0.size.equalTo(60)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        // "정인이네 알람" 라벨의 제약 조건
        alarmLabel.snp.makeConstraints {
            $0.top.equalTo(editButton.snp.bottom).offset(50)
            $0.leading.equalToSuperview().offset(10)
        }
        
        // "라인" 뷰의 제약 조건
        underlineView.snp.makeConstraints {
            $0.top.equalTo(alarmLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges).inset(10)
            $0.height.equalTo(1)
        }
        
        // "기타" 라벨의 제약 조건
        etcLabel.snp.makeConstraints {
            $0.top.equalTo(underlineView.snp.bottom).offset(90)
            $0.leading.equalToSuperview().offset(10)
        }
        
    }
    
    // MARK: - "+" 버튼을 클릭했을 때
    @objc private func plusButtonTapped() {
        
    }
}
