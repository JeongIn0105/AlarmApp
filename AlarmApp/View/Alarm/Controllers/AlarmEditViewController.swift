//
//  AlarmEditViewController.swift
//  AlarmApp
//
//  Created by 이정인 on 3/23/26.
//

import UIKit
import SnapKit
import Then

// MARK: - 알람 편집 화면 구현
final class AlarmEditViewController: UIViewController {
    
    // MARK: - 속성
    private let viewModel = AlarmViewModel.shared
    private let alarm: Alarm
    
    // MARK: - 편집할 알람 데이터를 전달받아 화면 초기화
    init(alarm: Alarm) {
        self.alarm = alarm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 설정
    private let closeButton = UIButton(type: .system).then {
        $0.setTitle("✕", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 26)
        $0.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        $0.layer.cornerRadius = 22
        $0.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    private let saveButton = UIButton(type: .system).then {
        $0.setTitle("✓", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 28)
        $0.backgroundColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1.0)
        $0.layer.cornerRadius = 22
        $0.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "알람 편집"
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 28)
        $0.textAlignment = .center
    }
    
    private let lineView = UIView().then {
        $0.backgroundColor = .white
    }
    
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
    
    private let formView = AlarmFormView()
    
    private let deleteAlarmButton = UIButton(type: .system).then {
        $0.setTitle("알람 삭제", for: .normal)
        $0.setTitleColor(.systemRed, for: .normal)
        $0.backgroundColor = UIColor(white: 0.35, alpha: 1.0)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 22)
        $0.layer.cornerRadius = 22
        $0.addTarget(self, action: #selector(deleteAlarmTapped), for: .touchUpInside)
    }
    
    // MARK: - 생명 주기
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureAlarmData()
        configureSwipeGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - 알람 편집 화면의 UI 및 제약 조건
    private func configureUI() {
        view.backgroundColor = .black
        
        [
            closeButton,
            saveButton,
            titleLabel,
            lineView,
            datePicker,
            formView,
            deleteAlarmButton
        ].forEach { view.addSubview($0) }
        
        closeButton.snp.makeConstraints {
            $0.size.equalTo(44)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        saveButton.snp.makeConstraints {
            $0.size.equalTo(44)
            $0.centerY.equalTo(closeButton)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(24)
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
        
        deleteAlarmButton.snp.makeConstraints {
            $0.top.equalTo(formView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(56)
        }
    }
    
    // MARK: - 왼쪽 스와이프 삭제 제스처
    private func configureSwipeGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleDeleteSwipe))
        swipeGesture.direction = .left
        swipeGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(swipeGesture)
    }
    
    // MARK: - 기존 알람 데이터를 화면에 표시
    private func configureAlarmData() {
        formView.configure(with: alarm)
        
        let hour24: Int
        if alarm.isAM {
            hour24 = alarm.hour == 12 ? 0 : alarm.hour
        } else {
            hour24 = alarm.hour == 12 ? 12 : alarm.hour + 12
        }
        
        var components = DateComponents()
        components.hour = hour24
        components.minute = alarm.minute
        
        if let date = Calendar.current.date(from: components) {
            datePicker.date = date
        }
    }
    
    // MARK: - 버튼 액션
    @objc
    private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func saveTapped() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: datePicker.date)
        
        guard let hour24 = components.hour,
              let minute = components.minute else { return }
        
        let isAM = hour24 < 12
        let hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24)
        
        let updatedAlarm = Alarm(
            id: alarm.id,
            hour: hour12,
            minute: minute,
            isAM: isAM,
            label: formView.currentLabelText(),
            repeatDays: formView.currentRepeatDays(),
            soundName: formView.currentSoundName(),
            isSnoozeEnabled: formView.currentSnoozeEnabled(),
            snoozeMinutes: formView.currentSnoozeMinutes(),
            isEnabled: alarm.isEnabled
        )
        
        viewModel.updateAlarm(updatedAlarm)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - 삭제 버튼 클릭
    @objc
    private func deleteAlarmTapped() {
        showDeleteAlert()
    }
    
    // MARK: - 왼쪽 스와이프
    @objc
    private func handleDeleteSwipe() {
        showDeleteAlert()
    }
    
    // MARK: - 삭제 확인 Alert
    private func showDeleteAlert() {
        let alert = UIAlertController(
            title: nil,
            message: "알람 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "네", style: .destructive) { [weak self] _ in
            self?.deleteCurrentAlarm()
        }
        
        let noAction = UIAlertAction(title: "아니요", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - 알람 삭제 공통 처리
    private func deleteCurrentAlarm() {
        viewModel.deleteAlarm(id: alarm.id)
        navigationController?.popViewController(animated: true)
    }
}
