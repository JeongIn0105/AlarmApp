//
//  TimerViewController.swift
//  AlarmApp
//

import UIKit
import SnapKit
import Then
import RxSwift

// MARK: 타이머 메인 화면(타이머 전체 코드 조립, 시작/취소 버튼, 화면 이동, 알림창 구현)
final class TimerViewController: UIViewController {
    
    private let viewModel = TimerViewModel()
    private let disposeBag = DisposeBag()
    
    private var isPushingTimerStart = false
    
    private let timerLabel = UILabel().then {
        $0.text = "타이머"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 28, weight: .heavy)
    }
    
    private let pickerViewController = TimePickerViewController()
    private lazy var recentViewController = TimeRecentViewController(viewModel: viewModel)
    
    private let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(UIColor(red: 1.0, green: 94/255, blue: 0, alpha: 1.0), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        $0.backgroundColor = UIColor(red: 95/255, green: 19/255, blue: 0, alpha: 1.0)
        $0.layer.cornerRadius = 35
        $0.clipsToBounds = true
    }
    
    private let startButton = UIButton().then {
        $0.setTitle("시작", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        $0.backgroundColor = UIColor.systemGreen
        $0.layer.cornerRadius = 35
        $0.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        embedChildren()
        bind()
        
        pickerViewController.setTime(hour: 0, minute: 7, second: 0)
        viewModel.updateSelectedDuration(pickerViewController.selectedDuration)
        recentViewController.updateLabelText(viewModel.labelText)
        recentViewController.updateSoundText(viewModel.displaySoundName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isPushingTimerStart = false
    }
    
    private func configureUI() {
        view.backgroundColor = .black
        
        [
            timerLabel,
            cancelButton,
            startButton
        ].forEach { view.addSubview($0) }
        
        timerLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.width.height.equalTo(70)
        }
        
        startButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.equalTo(70)
        }
    }
    
    private func embedChildren() {
        addChild(pickerViewController)
        view.addSubview(pickerViewController.view)
        pickerViewController.didMove(toParent: self)
        
        addChild(recentViewController)
        view.addSubview(recentViewController.view)
        recentViewController.didMove(toParent: self)
        
        pickerViewController.view.snp.makeConstraints {
            $0.top.equalTo(timerLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(pickerViewController.view.snp.bottom).offset(20)
        }
        
        startButton.snp.makeConstraints {
            $0.top.equalTo(pickerViewController.view.snp.bottom).offset(20)
        }
        
        recentViewController.view.snp.makeConstraints {
            $0.top.equalTo(cancelButton.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        pickerViewController.onTimeChanged = { [weak self] duration in
            self?.viewModel.updateSelectedDuration(duration)
        }
        
        recentViewController.onRecentItemSelected = { [weak self] index in
            guard let self else { return }
            self.viewModel.configureMainTimerFromRecent(at: index)
            self.moveToTimerStart()
        }
        
        recentViewController.onOpenLabel = { [weak self] in
            self?.showLabelAlert()
        }
        
        recentViewController.onOpenSound = { [weak self] in
            guard let self else { return }
            let vc = TimerSoundViewController(viewModel: self.viewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        
        viewModel.onTimerFinished = { [weak self] in
            guard let self else { return }
            TimerSoundPlayer.shared.playSound(named: self.viewModel.currentSoundFileName)
        }
        
        viewModel.onRecentTimerFinished = { [weak self] in
            guard let self else { return }
            TimerSoundPlayer.shared.playSound(named: self.viewModel.currentSoundFileName)
        }
        
        viewModel.onSelectedSoundChanged = { [weak self] soundText in
            self?.recentViewController.updateSoundText(soundText)
        }
        
        viewModel.onLabelChanged = { [weak self] text in
            self?.recentViewController.updateLabelText(text)
        }
    }
    
    @objc
    private func cancelTapped() {
        pickerViewController.setTime(hour: 0, minute: 0, second: 0)
        viewModel.updateSelectedDuration(0)
        TimerSoundPlayer.shared.stopSound()
    }
    
    @objc
    private func startTapped() {
        let duration = pickerViewController.selectedDuration
        guard duration > 0 else { return }
        
        viewModel.updateSelectedDuration(duration)
        viewModel.startTimer()
        moveToTimerStart()
    }
    
    private func moveToTimerStart() {
        guard !isPushingTimerStart else { return }
        isPushingTimerStart = true
        
        let startVC = TimerStartViewController(viewModel: viewModel)
        startVC.hidesBottomBarWhenPushed = false
        navigationController?.pushViewController(startVC, animated: true)
    }
    
    private func showLabelAlert() {
        let alert = UIAlertController(title: "레이블", message: nil, preferredStyle: .alert)
        
        alert.addTextField { [weak self] textField in
            textField.placeholder = "레이블 입력"
            textField.text = self?.viewModel.labelText
            textField.clearButtonMode = .whileEditing
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "저장", style: .default, handler: { [weak self] _ in
            let text = alert.textFields?.first?.text ?? ""
            self?.viewModel.updateLabel(text)
        }))
        
        present(alert, animated: true)
    }
}
