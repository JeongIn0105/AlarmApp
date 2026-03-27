//
//  TimePickerViewController.swift
//  AlarmApp
//
//  Created by 이정인 on 3/23/26.
//

import UIKit
import SnapKit
import Then

// MARK: 타이머 시간 / 분 / 초 Picker 구현
final class TimePickerViewController: UIViewController {
    
    // 시간 변경 시 외부로 값을 전달하기 위한 클로저
    var onTimeChanged: ((TimeInterval) -> Void)?
    
    // Picker에 사용할 데이터 배열
    private let hours = Array(0...23)     // 0 ~ 23시간
    private let minutes = Array(0...59)   // 0 ~ 59분
    private let seconds = Array(0...59)   // 0 ~ 59초
    
    // 현재 선택된 값 저장
    private var selectedHour: Int = 0
    private var selectedMinute: Int = 7
    private var selectedSecond: Int = 0
    
    // 선택된 시간을 TimeInterval(초)로 변환
    var selectedDuration: TimeInterval {
        TimeInterval((selectedHour * 3600) + (selectedMinute * 60) + selectedSecond)
    }
    
    // Picker를 담는 컨테이너 뷰
    private let pickerContainerView = UIView().then {
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
    }
    
    // 가운데 선택 영역 배경 (아이폰 스타일 강조 영역)
    private let selectionBackgroundView = UIView().then {
        $0.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
        $0.layer.cornerRadius = 18
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = false
    }
    
    // 실제 PickerView
    private let timePickerView = UIPickerView().then {
        $0.backgroundColor = .clear
    }
    
    // MARK: - 생명 주기
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()       // UI 배치
        configurePicker()   // Picker 설정
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Picker 기본 선 제거
        hidePickerLines()
    }
    
    // MARK: - 외부에서 시간 설정
    
    // 외부에서 특정 시간으로 초기 설정할 때 사용
    func setTime(hour: Int, minute: Int, second: Int) {
        
        // 값 범위 제한 (예외 방지)
        selectedHour = min(max(0, hour), 23)
        selectedMinute = min(max(0, minute), 59)
        selectedSecond = min(max(0, second), 59)
        
        // Picker 선택 위치 설정
        timePickerView.selectRow(selectedHour, inComponent: 0, animated: true)
        timePickerView.selectRow(selectedMinute, inComponent: 1, animated: true)
        timePickerView.selectRow(selectedSecond, inComponent: 2, animated: true)
        
        // UI 갱신
        timePickerView.reloadAllComponents()
        
        // 외부로 변경된 시간 전달
        onTimeChanged?(selectedDuration)
    }
    
    // MARK: - UI 구성
    
    private func configureUI() {
        view.backgroundColor = .clear
        
        // 뷰 계층 구성
        view.addSubview(pickerContainerView)
        pickerContainerView.addSubview(selectionBackgroundView)
        pickerContainerView.addSubview(timePickerView)
        
        // 컨테이너 전체 채우기
        pickerContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 가운데 선택 영역 (고정)
        selectionBackgroundView.snp.makeConstraints {
            $0.centerY.equalTo(pickerContainerView)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        // PickerView 전체 채우기
        timePickerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Picker 설정
    
    private func configurePicker() {
        
        // delegate / dataSource 연결
        timePickerView.delegate = self
        timePickerView.dataSource = self
        
        // 초기 선택값 설정
        timePickerView.selectRow(selectedHour, inComponent: 0, animated: false)
        timePickerView.selectRow(selectedMinute, inComponent: 1, animated: false)
        timePickerView.selectRow(selectedSecond, inComponent: 2, animated: false)
    }
    
    // MARK: - Picker 기본 선 제거
    
    private func hidePickerLines() {
        
        // Picker 내부 서브뷰 순회
        for subview in timePickerView.subviews {
            
            // 높이가 1 이하인 라인 제거
            if subview.frame.height <= 1 {
                subview.isHidden = true
            }
        }
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension TimePickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // Picker 컬럼 개수 (시, 분, 초)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        3
    }
    
    // 각 컬럼의 row 개수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return hours.count
        case 1: return minutes.count
        case 2: return seconds.count
        default: return 0
        }
    }
    
    // 각 컬럼의 너비
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let totalWidth = pickerView.bounds.width
        return totalWidth / 3.15
    }
    
    // 각 row 높이
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        44
    }
    
    // 각 row의 커스텀 뷰 구성
    func pickerView(
        _ pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        reusing view: UIView?
    ) -> UIView {
        
        // 현재 선택된 row인지 확인
        let isSelected = pickerView.selectedRow(inComponent: component) == row
        
        // 전체 컨테이너
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        // 숫자 라벨
        let valueLabel = UILabel()
        valueLabel.textAlignment = .right
        
        // 단위 라벨 (시간, 분, 초)
        let unitLabel = UILabel()
        unitLabel.textAlignment = .left
        
        // component에 따라 값 설정
        switch component {
        case 0:
            valueLabel.text = "\(hours[row])"
            unitLabel.text = "시간"
        case 1:
            valueLabel.text = "\(minutes[row])"
            unitLabel.text = "분"
        case 2:
            valueLabel.text = "\(seconds[row])"
            unitLabel.text = "초"
        default:
            break
        }
        
        // 선택된 상태 UI
        if isSelected {
            valueLabel.textColor = .white
            valueLabel.font = .systemFont(ofSize: 28, weight: .regular)
            
            unitLabel.textColor = .white
            unitLabel.font = .systemFont(ofSize: 18, weight: .regular)
        } else {
            // 선택되지 않은 상태 UI
            valueLabel.textColor = UIColor(white: 1.0, alpha: 0.28)
            valueLabel.font = .systemFont(ofSize: 23, weight: .regular)
            
            unitLabel.textColor = UIColor(white: 1.0, alpha: 0.28)
            unitLabel.font = .systemFont(ofSize: 16, weight: .regular)
        }
        
        // 뷰 추가
        containerView.addSubview(valueLabel)
        containerView.addSubview(unitLabel)
        
        // 숫자 라벨 레이아웃
        valueLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.56)
        }
        
        // 단위 라벨 레이아웃
        unitLabel.snp.makeConstraints {
            $0.leading.equalTo(valueLabel.snp.trailing).offset(4)
            $0.trailing.top.bottom.equalToSuperview()
        }
        
        return containerView
    }
    
    // Picker 선택 시 호출
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // 선택된 값 업데이트
        switch component {
        case 0:
            selectedHour = hours[row]
        case 1:
            selectedMinute = minutes[row]
        case 2:
            selectedSecond = seconds[row]
        default:
            break
        }
        
        // UI 갱신 (선택 강조 반영)
        pickerView.reloadAllComponents()
        
        // 외부로 시간 전달
        onTimeChanged?(selectedDuration)
    }
}
