//
//  TimerSoundViewController.swift
//  AlarmApp
//

import UIKit
import SnapKit
import Then

final class TimerSoundViewController: UIViewController {
    
    private let viewModel: TimerViewModel
    
    private let sounds = [
        "레디얼(기본 설정)",
        "걸음",
        "골짜기",
        "반향",
        "머큐리"
    ]
    
    private let containerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let closeButton = UIButton(type: .system).then {
        let image = UIImage(systemName: "xmark")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        )
        $0.setImage(image, for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = UIColor(white: 0.10, alpha: 1.0)
        $0.layer.cornerRadius = 18
        $0.clipsToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(white: 1.0, alpha: 0.08).cgColor
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "타이머 종료 시"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 28, weight: .bold)
        $0.textAlignment = .center
    }
    
    private let settingButton = UIButton(type: .system).then {
        $0.setTitle("설정", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        $0.backgroundColor = UIColor(red: 1.0, green: 149/255, blue: 0, alpha: 1.0)
        $0.layer.cornerRadius = 18
        $0.clipsToBounds = true
    }
    
    private let cardView = UIView().then {
        $0.backgroundColor = UIColor(white: 0.24, alpha: 1.0)
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    private var rowViews: [SoundRowView] = []
    
    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureRows()
        updateSelectionUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .black
        
        view.addSubview(containerView)
        
        [
            closeButton,
            titleLabel,
            settingButton,
            cardView
        ].forEach { containerView.addSubview($0) }

        cardView.addSubview(stackView)
        
        containerView.snp.makeConstraints {
            $0.centerY.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(60)
            $0.centerY.equalTo(titleLabel)
            $0.size.equalTo(36)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        settingButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-40)
            $0.width.equalTo(60)
            $0.height.equalTo(36)
        }
        
        cardView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(settingTapped), for: .touchUpInside)
    }
    
    private func configureRows() {
        for index in sounds.indices {
            let sound = sounds[index]
            let isLast = index == sounds.count - 1
            
            let row = SoundRowView()
            row.configure(title: sound, showsDivider: !isLast)
            
            row.onTap = { [weak self] in
                guard let self else { return }
                self.viewModel.updateSelectedSound(sound)
                self.updateSelectionUI()
            }
            
            stackView.addArrangedSubview(row)
            
            row.snp.makeConstraints {
                $0.height.equalTo(72)
            }
            
            rowViews.append(row)
        }
    }
    
    private func updateSelectionUI() {
        for index in rowViews.indices {
            let sound = sounds[index]
            let isSelected = viewModel.selectedSound == sound
            rowViews[index].setSelected(isSelected)
        }
    }
    
    @objc
    private func closeTapped() {
        moveToTimerScreen()
    }
    
    @objc
    private func settingTapped() {
        moveToTimerScreen()
    }
    
    private func moveToTimerScreen() {
        guard let navigationController else { return }
        
        if let startVC = navigationController.viewControllers.first(where: { $0 is TimerStartViewController }) {
            navigationController.popToViewController(startVC, animated: true)
            return
        }
        
        if let timerVC = navigationController.viewControllers.first(where: { $0 is TimerViewController }) {
            navigationController.popToViewController(timerVC, animated: true)
            return
        }
        
        navigationController.popViewController(animated: true)
    }
}

final class SoundRowView: UIView {
    
    var onTap: (() -> Void)?
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 18, weight: .bold)
    }
    
    private let checkImageView = UIImageView().then {
        $0.image = UIImage(systemName: "checkmark")
        $0.tintColor = UIColor(red: 1.0, green: 149/255, blue: 0, alpha: 1.0)
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(checkImageView)
        addSubview(dividerView)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
        
        checkImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        
        dividerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rowTapped))
        addGestureRecognizer(tapGesture)
    }
    
    func configure(title: String, showsDivider: Bool) {
        titleLabel.text = title
        dividerView.isHidden = !showsDivider
    }
    
    func setSelected(_ selected: Bool) {
        checkImageView.isHidden = !selected
    }
    
    @objc
    private func rowTapped() {
        onTap?()
    }
}
