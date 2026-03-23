//
//  AlarmFormView.swift
//  AlarmApp
//
//  Created by 이정인 on 3/23/26.
//

import UIKit
import SnapKit
import Then

// MARK: - 알람 추가 / 알람 편집 화면에서 공통으로 사용하는 폼 뷰
final class AlarmFormView: UIView {
    
    // MARK: - 선택 값 저장
    private(set) var selectedRepeatDays: [Weekday] = []
    private(set) var selectedSoundName: String = "레이더"
    private(set) var selectedSnoozeMinutes: Int = 7
    
    // MARK: - UI 설정
    private let repeatTitleLabel = UILabel().then {
        $0.text = "반복"
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 18)
    }
    
    private let repeatDaysLabel = UILabel().then {
        $0.text = "안 함"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textAlignment = .right
    }
    
    private let labelTitleLabel = UILabel().then {
        $0.text = "레이블"
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 18)
    }
    
    private let labelTextField = UITextField().then {
        $0.text = "알람"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textAlignment = .right
        $0.borderStyle = .none
    }
    
    private let soundTitleLabel = UILabel().then {
        $0.text = "사운드"
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 18)
    }
    
    private let soundNameLabel = UILabel().then {
        $0.text = "레이더"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textAlignment = .right
    }
    
    private let snoozeTitleLabel = UILabel().then {
        $0.text = "다시 알림"
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 18)
    }
    
    private let snoozeSwitch = UISwitch().then {
        $0.isOn = true
        $0.onTintColor = .systemGreen
    }
    
    private let snoozeDelayTitleLabel = UILabel().then {
        $0.text = "다시 알림 연기 시간"
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 18)
    }
    
    private let snoozeDelayLabel = UILabel().then {
        $0.text = "7분"
        $0.textColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0)
        $0.font = .boldSystemFont(ofSize: 18)
        $0.textAlignment = .right
    }
    
    private let topDivider = UIView().then {
        $0.backgroundColor = .darkGray
    }
    
    private let secondDivider = UIView().then {
        $0.backgroundColor = .darkGray
    }
    
    private let thirdDivider = UIView().then {
        $0.backgroundColor = .darkGray
    }
    
    private let bottomDivider = UIView().then {
        $0.backgroundColor = .darkGray
    }
    
    // MARK: - 생명 주기
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 구성
    private func configureUI() {
        backgroundColor = UIColor(white: 0.35, alpha: 1.0)
        layer.cornerRadius = 20
        
        [
            repeatTitleLabel, repeatDaysLabel, topDivider,
            labelTitleLabel, labelTextField, secondDivider,
            soundTitleLabel, soundNameLabel, thirdDivider,
            snoozeTitleLabel, snoozeSwitch, bottomDivider,
            snoozeDelayTitleLabel, snoozeDelayLabel
        ].forEach { addSubview($0) }
        
        repeatTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(18)
        }
        
        repeatDaysLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(repeatTitleLabel)
        }
        
        topDivider.snp.makeConstraints {
            $0.top.equalTo(repeatTitleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        
        labelTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(topDivider.snp.bottom).offset(16)
        }
        
        labelTextField.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(labelTitleLabel)
            $0.width.equalTo(180)
        }
        
        secondDivider.snp.makeConstraints {
            $0.top.equalTo(labelTitleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        
        soundTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(secondDivider.snp.bottom).offset(16)
        }
        
        soundNameLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(soundTitleLabel)
        }
        
        thirdDivider.snp.makeConstraints {
            $0.top.equalTo(soundTitleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        
        snoozeTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(thirdDivider.snp.bottom).offset(16)
        }
        
        snoozeSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(snoozeTitleLabel)
        }
        
        bottomDivider.snp.makeConstraints {
            $0.top.equalTo(snoozeTitleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        
        snoozeDelayTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(bottomDivider.snp.bottom).offset(16)
            $0.bottom.equalToSuperview().offset(-18)
        }
        
        snoozeDelayLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(snoozeDelayTitleLabel)
        }
    }
    
    // MARK: - 액션 연결
    private func setupActions() {
        let repeatTapGesture = UITapGestureRecognizer(target: self, action: #selector(repeatTapped))
        repeatDaysLabel.isUserInteractionEnabled = true
        repeatDaysLabel.addGestureRecognizer(repeatTapGesture)
        
        let soundTapGesture = UITapGestureRecognizer(target: self, action: #selector(soundTapped))
        soundNameLabel.isUserInteractionEnabled = true
        soundNameLabel.addGestureRecognizer(soundTapGesture)
        
        let snoozeDelayTapGesture = UITapGestureRecognizer(target: self, action: #selector(snoozeDelayTapped))
        snoozeDelayLabel.isUserInteractionEnabled = true
        snoozeDelayLabel.addGestureRecognizer(snoozeDelayTapGesture)
    }
    
    // MARK: - 외부에서 값 세팅
    func configure(with alarm: Alarm?) {
        guard let alarm else {
            labelTextField.text = "알람"
            repeatDaysLabel.text = "안 함"
            soundNameLabel.text = "레이더"
            snoozeSwitch.isOn = true
            snoozeDelayLabel.text = "7분"
            selectedRepeatDays = []
            selectedSoundName = "레이더"
            selectedSnoozeMinutes = 7
            return
        }
        
        labelTextField.text = alarm.label
        snoozeSwitch.isOn = alarm.isSnoozeEnabled
        selectedRepeatDays = alarm.repeatDays
        selectedSoundName = alarm.soundName
        selectedSnoozeMinutes = alarm.snoozeMinutes
        
        repeatDaysLabel.text = alarm.repeatDays.isEmpty
            ? "안 함"
            : alarm.repeatDays
                .sorted { $0.rawValue < $1.rawValue }
                .map { $0.koreanTitle }
                .joined(separator: ", ")
        
        soundNameLabel.text = alarm.soundName
        snoozeDelayLabel.text = "\(alarm.snoozeMinutes)분"
    }
    
    // MARK: - 외부에서 값 가져오기
    func currentLabelText() -> String {
        guard let text = labelTextField.text, !text.isEmpty else { return "알람" }
        return text
    }
    
    func currentRepeatDays() -> [Weekday] {
        selectedRepeatDays
    }
    
    func currentSoundName() -> String {
        selectedSoundName
    }
    
    func currentSnoozeMinutes() -> Int {
        selectedSnoozeMinutes
    }
    
    func currentSnoozeEnabled() -> Bool {
        snoozeSwitch.isOn
    }
    
    // MARK: - 반복 선택
    @objc private func repeatTapped() {
        guard let parentViewController else { return }
        
        let alert = UIAlertController(title: "반복", message: nil, preferredStyle: .actionSheet)
        
        Weekday.allCases.forEach { day in
            alert.addAction(UIAlertAction(title: day.koreanTitle, style: .default, handler: { _ in
                if self.selectedRepeatDays.contains(day) {
                    self.selectedRepeatDays.removeAll { $0 == day }
                } else {
                    self.selectedRepeatDays.append(day)
                }
                
                self.repeatDaysLabel.text = self.selectedRepeatDays.isEmpty
                    ? "안 함"
                    : self.selectedRepeatDays
                        .sorted { $0.rawValue < $1.rawValue }
                        .map { $0.koreanTitle }
                        .joined(separator: ", ")
            }))
        }
        
        alert.addAction(UIAlertAction(title: "초기화", style: .destructive, handler: { _ in
            self.selectedRepeatDays = []
            self.repeatDaysLabel.text = "안 함"
        }))
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        parentViewController.present(alert, animated: true)
    }
    
    // MARK: - 사운드 선택
    @objc private func soundTapped() {
        guard let parentViewController else { return }
        
        let alert = UIAlertController(title: "사운드", message: nil, preferredStyle: .actionSheet)
        
        let soundNames = ["레이더", "기본", "벨", "차임"]
        soundNames.forEach { soundName in
            alert.addAction(UIAlertAction(title: soundName, style: .default, handler: { _ in
                self.selectedSoundName = soundName
                self.soundNameLabel.text = soundName
            }))
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        parentViewController.present(alert, animated: true)
    }
    
    // MARK: - 다시 알림 시간 선택
    @objc private func snoozeDelayTapped() {
        guard let parentViewController else { return }
        
        let alert = UIAlertController(title: "다시 알림 연기 시간", message: nil, preferredStyle: .actionSheet)
        
        [5, 7, 9, 10, 15].forEach { minute in
            alert.addAction(UIAlertAction(title: "\(minute)분", style: .default, handler: { _ in
                self.selectedSnoozeMinutes = minute
                self.snoozeDelayLabel.text = "\(minute)분"
            }))
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        parentViewController.present(alert, animated: true)
    }
}

// MARK: - 부모 ViewController 찾기
private extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            responder = nextResponder
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
