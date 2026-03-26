//
//  TimerCell.swift
//  AlarmApp
//

import UIKit
import SnapKit
import Then

struct TimerRecentItem {
    let duration: TimeInterval
    let title: String
}

final class TimerCell: UITableViewCell {
    
    static let id = "TimerCell"
    
    private let timeLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 26, weight: .bold)
        $0.numberOfLines = 1
    }
    
    private let minuteLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 1
    }
    
    private let deleteBackgroundView = UIView().then {
        $0.backgroundColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
    }
    
    private let deleteImageView = UIImageView().then {
        $0.image = UIImage(systemName: "trash.fill")
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
    }
    
    private let deleteButton = UIButton(type: .system)
    
    private let playBackgroundView = UIView().then {
        $0.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
    }
    
    private let playImageView = UIImageView().then {
        $0.image = UIImage(systemName: "play.fill")
        $0.tintColor = UIColor(red: 0.10, green: 0.78, blue: 0.22, alpha: 1.0)
        $0.contentMode = .scaleAspectFit
    }
    
    private let playButton = UIButton(type: .system)
    
    var onTapPlay: (() -> Void)?
    var onTapDelete: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .black
        contentView.backgroundColor = .black
        selectionStyle = .none
        
        [
            timeLabel,
            minuteLabel,
            deleteBackgroundView,
            deleteButton,
            playBackgroundView,
            playButton
        ].forEach { contentView.addSubview($0) }
        
        deleteBackgroundView.addSubview(deleteImageView)
        playBackgroundView.addSubview(playImageView)
        
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.lessThanOrEqualTo(deleteBackgroundView.snp.leading).offset(-10)
        }
        
        minuteLabel.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(1)
            $0.leading.equalTo(timeLabel)
            $0.bottom.equalToSuperview().offset(-8)
            $0.trailing.lessThanOrEqualTo(deleteBackgroundView.snp.leading).offset(-10)
        }
        
        playBackgroundView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-4)
            $0.width.height.equalTo(48)
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
            $0.trailing.equalTo(playBackgroundView.snp.leading).offset(-8)
            $0.width.height.equalTo(48)
        }
        
        deleteImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(18)
        }
        
        deleteButton.snp.makeConstraints {
            $0.edges.equalTo(deleteBackgroundView)
        }
        
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    func configure(item: TimerRecentItem) {
        let totalSeconds = Int(item.duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
        minuteLabel.text = item.title
    }
    
    func animateDelete(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.18, animations: {
            self.contentView.alpha = 0
            self.contentView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            self.contentView.alpha = 1
            self.contentView.transform = .identity
            completion()
        }
    }
    
    @objc
    private func playTapped() {
        onTapPlay?()
    }
    
    @objc
    private func deleteTapped() {
        onTapDelete?()
    }
}

