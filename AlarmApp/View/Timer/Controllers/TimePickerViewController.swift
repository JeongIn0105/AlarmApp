//
//  TimePickerViewController.swift
//  AlarmApp
//

import UIKit
import SnapKit
import Then

// MARK: 타이머 시간 / 분 / 초 Picker 구현
final class TimePickerViewController: UIViewController {
    
    var onTimeChanged: ((TimeInterval) -> Void)?
    
    private let hours = Array(0...23)
    private let minutes = Array(0...59)
    private let seconds = Array(0...59)
    
    private var selectedHour: Int = 0
    private var selectedMinute: Int = 7
    private var selectedSecond: Int = 0
    
    var selectedDuration: TimeInterval {
        TimeInterval((selectedHour * 3600) + (selectedMinute * 60) + selectedSecond)
    }
    
    private let pickerContainerView = UIView().then {
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
    }
    
    private let selectionBackgroundView = UIView().then {
        $0.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
        $0.layer.cornerRadius = 18
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = false
    }
    
    private let timePickerView = UIPickerView().then {
        $0.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configurePicker()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hidePickerLines()
    }
    
    func setTime(hour: Int, minute: Int, second: Int) {
        selectedHour = min(max(0, hour), 23)
        selectedMinute = min(max(0, minute), 59)
        selectedSecond = min(max(0, second), 59)
        
        timePickerView.selectRow(selectedHour, inComponent: 0, animated: true)
        timePickerView.selectRow(selectedMinute, inComponent: 1, animated: true)
        timePickerView.selectRow(selectedSecond, inComponent: 2, animated: true)
        timePickerView.reloadAllComponents()
        
        onTimeChanged?(selectedDuration)
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
        
        view.addSubview(pickerContainerView)
        pickerContainerView.addSubview(selectionBackgroundView)
        pickerContainerView.addSubview(timePickerView)
        
        pickerContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        selectionBackgroundView.snp.makeConstraints {
            $0.centerY.equalTo(pickerContainerView)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        timePickerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configurePicker() {
        timePickerView.delegate = self
        timePickerView.dataSource = self
        
        timePickerView.selectRow(selectedHour, inComponent: 0, animated: false)
        timePickerView.selectRow(selectedMinute, inComponent: 1, animated: false)
        timePickerView.selectRow(selectedSecond, inComponent: 2, animated: false)
    }
    
    private func hidePickerLines() {
        for subview in timePickerView.subviews {
            if subview.frame.height <= 1 {
                subview.isHidden = true
            }
        }
    }
}

extension TimePickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return hours.count
        case 1: return minutes.count
        case 2: return seconds.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let totalWidth = pickerView.bounds.width
        return totalWidth / 3.15
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        44
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let isSelected = pickerView.selectedRow(inComponent: component) == row
        
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        let valueLabel = UILabel()
        valueLabel.textAlignment = .right
        
        let unitLabel = UILabel()
        unitLabel.textAlignment = .left
        
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
        
        if isSelected {
            valueLabel.textColor = .white
            valueLabel.font = .systemFont(ofSize: 28, weight: .regular)
            unitLabel.textColor = .white
            unitLabel.font = .systemFont(ofSize: 18, weight: .regular)
        } else {
            valueLabel.textColor = UIColor(white: 1.0, alpha: 0.28)
            valueLabel.font = .systemFont(ofSize: 23, weight: .regular)
            unitLabel.textColor = UIColor(white: 1.0, alpha: 0.28)
            unitLabel.font = .systemFont(ofSize: 16, weight: .regular)
        }
        
        containerView.addSubview(valueLabel)
        containerView.addSubview(unitLabel)
        
        valueLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.56)
        }
        
        unitLabel.snp.makeConstraints {
            $0.leading.equalTo(valueLabel.snp.trailing).offset(4)
            $0.trailing.top.bottom.equalToSuperview()
        }
        
        return containerView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
        
        pickerView.reloadAllComponents()
        onTimeChanged?(selectedDuration)
    }
}
