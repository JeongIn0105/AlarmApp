//
//  StopwatchCell.swift
//  AlarmApp
//
//  Created by 이정인 on 3/24/26.
//

import UIKit
import SnapKit
import Then

// MARK: - 스톱워치 랩 셀 (테이블 뷰 셀)
final class StopwatchCell: UITableViewCell {
    
    // MARK: - 셀 재사용 식별자
    static let id = "StopwatchCell"
    
    // MARK: - UI 구성 요소
    // 랩 번호 표시 라벨 (예: 랩 1, 랩 2)
    private let lapLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 18, weight: .bold)
    }
    
    // 랩 시간 표시 라벨 (예: 00:33.33)
    private let timeLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        $0.textAlignment = .right
    }
    
    // MARK: - 초기화
    // 코드로 생성될 때 호출
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellUI()
    }
    
    // 스토리보드 사용 안 함
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 설정
    // 셀 UI 구성 및 레이아웃 설정
    private func configureCellUI() {
        backgroundColor = .black
        contentView.backgroundColor = .black
        selectionStyle = .none // 셀 선택 효과 제거
        
        // 라벨 추가
        contentView.addSubview(lapLabel)
        contentView.addSubview(timeLabel)
        
        lapLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }
    }
    
    // MARK: - 데이터 바인딩(셀에 데이터 적용)
    func configure(lapNumber: Int, timeText: String) {
        lapLabel.text = "랩 \(lapNumber)" // 랩 번호 (예: 1, 2, 3...)
        timeLabel.text = timeText // 랩 시간 문자열
    }
}
