//
//  AlarmCell.swift
//  AlarmApp
//
//  Created by 이정인 on 3/23/26.
//

import UIKit
import SnapKit
import Then

// MARK: - 알람 목록 화면에서 사용하는 테이블 뷰 셀
final class AlarmCell: UITableViewCell {
    
    static let id = "AlarmCell"
    
    // 스위치 상태 변경 시 ViewController로 값을 전달하는 클로저
    var onSwitchChanged: ((Bool) -> Void)?
    
    // 삭제 버튼 탭 시 ViewController로 이벤트를 전달하는 클로저
    var onDeleteTapped: (() -> Void)?
    
    // MARK: - UI 설정
    private let meridiemLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
    }
    
    private let timeLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 34)
    }
    
    private let alarmTitleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.text = "알람"
    }
    
    private let alarmSwitch = UISwitch().then {
        $0.onTintColor = .systemGreen
    }
    
    private let deleteButton = UIButton().then {
        $0.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .systemRed
        $0.layer.cornerRadius = 18
        $0.isHidden = true
    }
    
    private let chevronImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .white
        $0.isHidden = true
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private lazy var timeStackView = UIStackView(arrangedSubviews: [meridiemLabel, timeLabel]).then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .lastBaseline
    }
    
    private lazy var leftStackView = UIStackView(arrangedSubviews: [timeStackView, alarmTitleLabel]).then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.alignment = .leading
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 셀의 기본 UI 및 제약 조건 설정
    private func configureUI() {
        backgroundColor = .black
        contentView.backgroundColor = .black
        selectionStyle = .none
        
        [deleteButton, leftStackView, alarmSwitch, chevronImageView, dividerView].forEach {
            contentView.addSubview($0)
        }
        
        deleteButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(36)
        }
        
        leftStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(18)
            $0.bottom.equalToSuperview().offset(-18)
        }
        
        alarmSwitch.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        chevronImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(10)
            $0.height.equalTo(18)
        }
        
        dividerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(1)
        }
        
        alarmSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    // MARK: - 알람 데이터와 편집 모드 여부에 따라 셀 UI 업데이트
    func configure(with alarm: Alarm, isEditing: Bool) {
        meridiemLabel.text = alarm.meridiemText
        timeLabel.text = alarm.timeText
        alarmTitleLabel.text = alarm.label
        alarmSwitch.isOn = alarm.isEnabled
        
        let textColor: UIColor = alarm.isEnabled ? .white : .gray
        meridiemLabel.textColor = textColor
        timeLabel.textColor = textColor
        alarmTitleLabel.textColor = textColor
        
        // MARK: 편집 모드일 때는 삭제 버튼과 이동 화살표를 보여주고, 일반 모드일 때는 스위치를 표시
        deleteButton.isHidden = !isEditing
        chevronImageView.isHidden = !isEditing
        alarmSwitch.isHidden = isEditing
        
        // MARK: 편집 모드 여부에 따라 왼쪽 내용의 시작 위치를 다르게 설정
        leftStackView.snp.remakeConstraints {
            $0.leading.equalToSuperview().offset(isEditing ? 70 : 20)
            $0.top.equalToSuperview().offset(18)
            $0.bottom.equalToSuperview().offset(-18)
        }
    }
    
    // MARK: - 스위치 변경 이벤트 전달
    @objc private func switchValueChanged() {
        onSwitchChanged?(alarmSwitch.isOn)
    }
    
    // MARK: - 삭제 버튼 탭 이벤트 전달
    @objc private func deleteTapped() {
        onDeleteTapped?()
    }
}
