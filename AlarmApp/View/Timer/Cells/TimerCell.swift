//
//  TimerCell.swift
//  AlarmApp
//

import UIKit
import SnapKit
import Then

// MARK: - 최근 타이머 데이터 모델
// 최근 사용한 타이머 정보를 저장하는 구조체
struct TimerRecentItem: Codable {
    
    // 고유 식별자
    let id: UUID
    
    // 처음 설정한 시간
    let originalDuration: TimeInterval
    
    // 현재 남은 시간
    var remainingDuration: TimeInterval
    
    // 타이머 이름 (예: "라면", "공부")
    let title: String
    
    // 실행 중 여부
    var isRunning: Bool
    
    // 초기화
    init(
        id: UUID = UUID(),
        originalDuration: TimeInterval,
        remainingDuration: TimeInterval? = nil,
        title: String,
        isRunning: Bool = false
    ) {
        self.id = id
        self.originalDuration = originalDuration
        
        // remainingDuration이 없으면 originalDuration으로 설정
        self.remainingDuration = remainingDuration ?? originalDuration
        
        self.title = title
        self.isRunning = isRunning
    }
}

// MARK: - 최근 타이머 셀
final class TimerCell: UITableViewCell {
    
    // 셀 재사용 identifier
    static let id = "TimerCell"
    
    // 재생 버튼 클릭 시 호출되는 클로저
    var onTapPlay: (() -> Void)?
    
    // 초기화(리셋) 버튼 클릭 시 호출되는 클로저
    var onTapDelete: (() -> Void)?
    
    // 전체 컨테이너 뷰
    private let containerView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 18
        $0.clipsToBounds = true
    }
    
    // 시간 표시 라벨 (예: 07:30)
    private let timeLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 28, weight: .semibold)
        $0.numberOfLines = 1
    }
    
    // 타이머 이름 라벨
    private let minuteLabel = UILabel().then {
        $0.textColor = UIColor(white: 1.0, alpha: 0.7)
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.numberOfLines = 1
    }
    
    // 실행 중 배지 배경
    private let runningBadgeView = UIView().then {
        $0.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
        $0.layer.cornerRadius = 8
        $0.isHidden = true
    }
    
    // 실행 중 텍스트
    private let runningBadgeLabel = UILabel().then {
        $0.text = "실행 중"
        $0.textColor = .systemOrange
        $0.font = .systemFont(ofSize: 10, weight: .semibold)
        $0.textAlignment = .center
    }
    
    // 초기화 버튼 배경
    private let deleteBackgroundView = UIView().then {
        $0.backgroundColor = .systemBrown
        $0.layer.cornerRadius = 22
        $0.clipsToBounds = true
        
        // 터치 이벤트는 버튼이 담당
        $0.isUserInteractionEnabled = false
    }
    
    // 초기화 아이콘 (되돌리기)
    private let deleteImageView = UIImageView().then {
        $0.image = UIImage(systemName: "arrow.counterclockwise")
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
    }
    
    // 초기화 버튼 (실제 터치 영역)
    private let deleteButton = UIButton(type: .custom).then {
        $0.backgroundColor = .clear
    }
    
    // 재생 버튼 배경
    private let playBackgroundView = UIView().then {
        $0.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.95)
        $0.layer.cornerRadius = 22
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = false
    }
    
    // 재생 / 일시정지 아이콘
    private let playImageView = UIImageView().then {
        $0.tintColor = UIColor(red: 0.10, green: 0.60, blue: 0.15, alpha: 1.0)
        $0.contentMode = .scaleAspectFit
    }
    
    // 재생 버튼 터치 영역
    private let playButton = UIButton(type: .custom).then {
        $0.backgroundColor = .clear
    }
    
    // 셀 구분선
    private let separatorLine = UIView().then {
        $0.backgroundColor = UIColor(white: 1.0, alpha: 0.10)
    }
    
    // MARK: - 초기화
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 셀 재사용 시 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 기존 이벤트 제거
        onTapPlay = nil
        onTapDelete = nil
    }
    
    // MARK: - UI 구성
    
    private func configureUI() {
        backgroundColor = .black
        contentView.backgroundColor = .black
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        
        [
            timeLabel,
            minuteLabel,
            runningBadgeView,
            deleteBackgroundView,
            deleteButton,
            playBackgroundView,
            playButton,
            separatorLine
        ].forEach { containerView.addSubview($0) }
        
        runningBadgeView.addSubview(runningBadgeLabel)
        deleteBackgroundView.addSubview(deleteImageView)
        playBackgroundView.addSubview(playImageView)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 시간 위치
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview()
        }
        
        // 타이머 이름 위치
        minuteLabel.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(4)
            $0.leading.equalTo(timeLabel)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        // 실행 중 배지
        runningBadgeView.snp.makeConstraints {
            $0.leading.equalTo(minuteLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(minuteLabel)
            $0.height.equalTo(16)
        }
        
        runningBadgeLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6))
        }
        
        // 재생 버튼
        playBackgroundView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(44)
        }
        
        playImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(18)
        }
        
        playButton.snp.makeConstraints {
            $0.edges.equalTo(playBackgroundView)
        }
        
        // 초기화 버튼
        deleteBackgroundView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(playBackgroundView.snp.leading).offset(-10)
            $0.width.height.equalTo(44)
        }
        
        deleteImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(18)
        }
        
        deleteButton.snp.makeConstraints {
            $0.edges.equalTo(deleteBackgroundView)
        }
        
        // 구분선
        separatorLine.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        // 버튼 액션 연결
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    // MARK: - 데이터 바인딩
    
    func configure(item: TimerRecentItem) {
        
        // 남은 시간을 초 단위로 변환
        let totalSeconds = max(0, Int(item.remainingDuration))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        // 시간 표시
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
        // 타이머 이름 표시
        minuteLabel.text = item.title
        
        if item.isRunning {
            // 실행 중 상태 UI
            containerView.backgroundColor = UIColor(white: 1.0, alpha: 0.04)
            runningBadgeView.isHidden = false
            
            playBackgroundView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.95)
            playImageView.image = UIImage(systemName: "pause.fill")
            playImageView.tintColor = UIColor(red: 0.95, green: 0.60, blue: 0.25, alpha: 1.0)
        } else {
            // 정지 상태 UI
            containerView.backgroundColor = .clear
            runningBadgeView.isHidden = true
            
            playBackgroundView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.95)
            playImageView.image = UIImage(systemName: "play.fill")
            playImageView.tintColor = UIColor(red: 0.10, green: 0.60, blue: 0.15, alpha: 1.0)
        }
    }
    
    // MARK: - 삭제 애니메이션
    
    func animateDelete(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.18, animations: {
            self.contentView.alpha = 0
            self.contentView.transform = CGAffineTransform(translationX: -16, y: 0)
        }) { _ in
            self.contentView.alpha = 1
            self.contentView.transform = .identity
            completion()
        }
    }
    
    // MARK: - 버튼 액션
    
    @objc
    private func playTapped() {
        animateButton(playBackgroundView)
        onTapPlay?()
    }
    
    @objc
    private func deleteTapped() {
        animateButton(deleteBackgroundView)
        onTapDelete?()
    }
    
    // 버튼 클릭 애니메이션
    private func animateButton(_ view: UIView) {
        UIView.animate(withDuration: 0.08, animations: {
            view.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                view.transform = .identity
            }
        }
    }
}
