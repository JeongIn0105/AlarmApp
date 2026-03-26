//
//  TimerCell.swift
//  AlarmApp
//

import UIKit
import SnapKit
import Then

struct TimerRecentItem: Codable {
    let id: UUID
    let originalDuration: TimeInterval
    var remainingDuration: TimeInterval
    let title: String
    var isRunning: Bool
    
    init(
        id: UUID = UUID(),
        originalDuration: TimeInterval,
        remainingDuration: TimeInterval? = nil,
        title: String,
        isRunning: Bool = false
    ) {
        self.id = id
        self.originalDuration = originalDuration
        self.remainingDuration = remainingDuration ?? originalDuration
        self.title = title
        self.isRunning = isRunning
    }
}

final class TimerCell: UITableViewCell {
    
    static let id = "TimerCell"
    
    var onTapPlay: (() -> Void)?
    var onTapDelete: (() -> Void)?
    
    private let containerView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 18
        $0.clipsToBounds = true
    }
    
    private let timeLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 28, weight: .semibold)
        $0.numberOfLines = 1
    }
    
    private let minuteLabel = UILabel().then {
        $0.textColor = UIColor(white: 1.0, alpha: 0.7)
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.numberOfLines = 1
    }
    
    private let runningBadgeView = UIView().then {
        $0.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
        $0.layer.cornerRadius = 8
        $0.isHidden = true
    }
    
    private let runningBadgeLabel = UILabel().then {
        $0.text = "실행 중"
        $0.textColor = .systemOrange
        $0.font = .systemFont(ofSize: 10, weight: .semibold)
        $0.textAlignment = .center
    }
    
    private let deleteBackgroundView = UIView().then {
        $0.backgroundColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
        $0.layer.cornerRadius = 22
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = false
    }
    
    private let deleteImageView = UIImageView().then {
        $0.image = UIImage(systemName: "trash")
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
    }
    
    private let deleteButton = UIButton(type: .custom).then {
        $0.backgroundColor = .clear
    }
    
    private let playBackgroundView = UIView().then {
        $0.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.95)
        $0.layer.cornerRadius = 22
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = false
    }
    
    private let playImageView = UIImageView().then {
        $0.tintColor = UIColor(red: 0.10, green: 0.60, blue: 0.15, alpha: 1.0)
        $0.contentMode = .scaleAspectFit
    }
    
    private let playButton = UIButton(type: .custom).then {
        $0.backgroundColor = .clear
    }
    
    private let separatorLine = UIView().then {
        $0.backgroundColor = UIColor(white: 1.0, alpha: 0.10)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onTapPlay = nil
        onTapDelete = nil
    }
    
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
        
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview()
        }
        
        minuteLabel.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(4)
            $0.leading.equalTo(timeLabel)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        runningBadgeView.snp.makeConstraints {
            $0.leading.equalTo(minuteLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(minuteLabel)
            $0.height.equalTo(16)
        }
        
        runningBadgeLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6))
        }
        
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
        
        separatorLine.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    func configure(item: TimerRecentItem) {
        let totalSeconds = max(0, Int(item.remainingDuration))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
        minuteLabel.text = item.title
        
        if item.isRunning {
            containerView.backgroundColor = UIColor(white: 1.0, alpha: 0.04)
            runningBadgeView.isHidden = false
            
            playBackgroundView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.95)
            playImageView.image = UIImage(systemName: "pause.fill")
            playImageView.tintColor = UIColor(red: 0.95, green: 0.60, blue: 0.25, alpha: 1.0)
        } else {
            containerView.backgroundColor = .clear
            runningBadgeView.isHidden = true
            
            playBackgroundView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.95)
            playImageView.image = UIImage(systemName: "play.fill")
            playImageView.tintColor = UIColor(red: 0.10, green: 0.60, blue: 0.15, alpha: 1.0)
        }
    }
    
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

