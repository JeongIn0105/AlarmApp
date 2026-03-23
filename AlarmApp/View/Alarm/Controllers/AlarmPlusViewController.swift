//
//  AlarmPlusViewController.swift
//  AlarmApp
//
//  Created by 이정인 on 3/20/26.
//

import UIKit
import SnapKit
import Then

// MARK: - 알람 추가 화면 구현
final class AlarmPlusViewController: UIViewController {
    
    // MARK: - 속성
    private let viewModel = AlarmViewModel.shared // 알람 데이터 저장 및 알림 예약을 담당하는 viewModel
    
    // MARK: - UI 설정
    private let backButton = UIButton(type: .system).then {
        $0.setTitle("✕", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 26)
        $0.backgroundColor = UIColor(red: 255/255, green: 94/255, blue: 0/255, alpha: 1.0)
        $0.layer.cornerRadius = 22
        $0.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    private let saveButton = UIButton(type: .system).then {
        $0.setTitle("✓", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 28)
        $0.backgroundColor = UIColor(red: 255/255, green: 94/255, blue: 0/255, alpha: 1.0)
        $0.layer.cornerRadius = 22
        $0.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "알람 추가"
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 28)
        $0.textAlignment = .center
    }
    
    private let lineView = UIView().then {
        $0.backgroundColor = .white
    }
    
    // 시간 선택하는 휠 UI 생성
    private let datePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.preferredDatePickerStyle = .wheels
        $0.locale = Locale(identifier: "ko_KR")
        $0.tintColor = .white
        $0.setValue(UIColor.white, forKey: "textColor")
        $0.backgroundColor = .clear
        $0.overrideUserInterfaceStyle = .dark
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    
    private let formView = AlarmFormView() // 알람 추가 / 편집 화면에서 공통으로 사용하는 입력 폼 뷰
    
    // MARK: - 생명 주기
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDefaultData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - 알림 추가 화면의 UI 및 제약 조건
    private func configureUI() {
        view.backgroundColor = .black
        
        [
            backButton,
            saveButton,
            titleLabel,
            lineView,
            datePicker,
            formView
        ].forEach { view.addSubview($0) }
        
        backButton.snp.makeConstraints {
            $0.size.equalTo(44)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        saveButton.snp.makeConstraints {
            $0.size.equalTo(44)
            $0.centerY.equalTo(backButton)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }
        
        lineView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(220)
        }
        
        formView.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(30)
        }
    }
    
    // MARK: - 알람 추가 화면의 기본 입력값 설정
    private func configureDefaultData() {
        formView.configure(with: nil)
    }
    
    // MARK: - 버튼 액션
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - 입력한 값을 바탕으로 새로운 알람 생성 및 저장
    @objc private func saveTapped() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: datePicker.date)
        
        guard let hour24 = components.hour, let minute = components.minute else { return }
        
        // MARK: DatePicker의 시간을 오전 / 오후 형식으로 변환
        let isAM = hour24 < 12
        let hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24)
        
        let alarm = Alarm(
            hour: hour12,
            minute: minute,
            isAM: isAM,
            label: formView.currentLabelText(),
            repeatDays: formView.currentRepeatDays(),
            soundName: formView.currentSoundName(),
            isSnoozeEnabled: formView.currentSnoozeEnabled(),
            snoozeMinutes: formView.currentSnoozeMinutes(),
            isEnabled: true
        )
        
        viewModel.addAlarm(alarm)
        navigationController?.popViewController(animated: true)
    }
}
