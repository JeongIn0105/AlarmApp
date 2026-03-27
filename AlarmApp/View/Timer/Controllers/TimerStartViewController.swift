//
//  TimerStartViewController.swift
//  AlarmApp
//
//  Created by 이정인 on 3/23/26.
//

import UIKit
import SnapKit
import Then
import AVFoundation

// MARK: - 타이머 시작 화면 구현
final class TimerStartViewController: UIViewController {
    
    private let viewModel: TimerViewModel
    private var audioPlayer: AVAudioPlayer?
    
    private let circleContainerView = UIView()
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private var previousProgress: CGFloat = 1.0
    private var totalDuration: TimeInterval = 0
    
    private let titleLabel = UILabel().then {
        $0.text = "10분"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 30, weight: .bold)
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.8
    }
    
    private let endTimeLabel = UILabel().then {
        $0.text = "🔔 오전 9:55"
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.8
    }
    
    private let remainTimeLabel = UILabel().then {
        $0.text = "06:58"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 50, weight: .heavy)
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.7
    }
    
    private let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(UIColor(red: 1.0, green: 94/255, blue: 0, alpha: 1.0), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        $0.backgroundColor = UIColor(red: 95/255, green: 19/255, blue: 0, alpha: 1.0)
        $0.layer.cornerRadius = 45
        $0.clipsToBounds = true
    }
    
    private let pauseButton = UIButton().then {
        $0.setTitle("일시 정지", for: .normal)
        $0.setTitleColor(.orange, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        $0.backgroundColor = UIColor(red: 96/255, green: 50/255, blue: 0, alpha: 1.0)
        $0.layer.cornerRadius = 45
        $0.clipsToBounds = true
    }
    
    private let infoContainerView = UIView().then {
        $0.backgroundColor = UIColor(white: 0.22, alpha: 1.0)
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    
    private let topInfoTitleLabel = UILabel().then {
        $0.text = "레이블"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 17, weight: .bold)
    }
    
    private let topInfoValueLabel = UILabel().then {
        $0.text = "타이머"
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 17, weight: .medium)
        $0.textAlignment = .right
    }
    
    private let dividerLine = UIView().then {
        $0.backgroundColor = UIColor(white: 0.32, alpha: 1.0)
    }
    
    private let bottomInfoTitleLabel = UILabel().then {
        $0.text = "타이머 종료 시"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 17, weight: .bold)
    }
    
    private let bottomInfoValueLabel = UILabel().then {
        $0.text = "레디얼 >"
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 17, weight: .medium)
        $0.textAlignment = .right
    }
    
    private let topRowButton = UIButton(type: .system)
    private let bottomRowButton = UIButton(type: .system)
    
    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
        self.totalDuration = viewModel.selectedDuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureUI()
        configureCircle()
        bindViewModel()
        
        titleLabel.text = viewModel.titleText(viewModel.selectedDuration)
        remainTimeLabel.text = viewModel.formatTime(viewModel.remainingTime)
        endTimeLabel.text = viewModel.endTimeText(viewModel.remainingTime)
        topInfoValueLabel.text = viewModel.labelText
        bottomInfoValueLabel.text = viewModel.displaySoundName
        updateProgress(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        circleContainerView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        circleContainerView.alpha = 0.85
        
        UIView.animate(withDuration: 0.28) {
            self.circleContainerView.transform = .identity
            self.circleContainerView.alpha = 1.0
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCirclePath()
    }
    
    private func configureNavigation() {
        title = ""
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func configureUI() {
        view.backgroundColor = .black
        
        [
            titleLabel,
            circleContainerView,
            cancelButton,
            pauseButton,
            infoContainerView
        ].forEach { view.addSubview($0) }
        
        [
            endTimeLabel,
            remainTimeLabel
        ].forEach { circleContainerView.addSubview($0) }
        
        [
            topInfoTitleLabel,
            topInfoValueLabel,
            dividerLine,
            bottomInfoTitleLabel,
            bottomInfoValueLabel,
            topRowButton,
            bottomRowButton
        ].forEach { infoContainerView.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        circleContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(64)
            $0.height.equalTo(circleContainerView.snp.width)
        }
        
        endTimeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-35)
            $0.leading.greaterThanOrEqualToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        
        remainTimeLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(endTimeLabel.snp.bottom).offset(6)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(circleContainerView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(40)
            $0.width.height.equalTo(90)
        }
        
        pauseButton.snp.makeConstraints {
            $0.top.equalTo(circleContainerView.snp.bottom).offset(16)
            $0.trailing.equalToSuperview().offset(-40)
            $0.width.height.equalTo(90)
        }
        
        infoContainerView.snp.makeConstraints {
            $0.top.equalTo(cancelButton.snp.bottom).offset(22)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(116)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(76)
        }
        
        topInfoTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(18)
        }
        
        topInfoValueLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(topInfoTitleLabel)
        }
        
        dividerLine.snp.makeConstraints {
            $0.top.equalTo(topInfoTitleLabel.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        bottomInfoTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(dividerLine.snp.bottom).offset(18)
        }
        
        bottomInfoValueLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(bottomInfoTitleLabel)
        }
        
        topRowButton.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(dividerLine.snp.top)
        }
        
        bottomRowButton.snp.makeConstraints {
            $0.top.equalTo(dividerLine.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
        topRowButton.addTarget(self, action: #selector(topRowTapped), for: .touchUpInside)
        bottomRowButton.addTarget(self, action: #selector(bottomRowTapped), for: .touchUpInside)
    }
    
    private func configureCircle() {
        trackLayer.strokeColor = UIColor(white: 0.18, alpha: 1.0).cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 8
        trackLayer.lineCap = .round
        
        progressLayer.strokeColor = UIColor.orange.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 8
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 1.0
        
        circleContainerView.layer.addSublayer(trackLayer)
        circleContainerView.layer.addSublayer(progressLayer)
    }
    
    private func updateCirclePath() {
        let center = CGPoint(x: circleContainerView.bounds.midX, y: circleContainerView.bounds.midY)
        let radius = (min(circleContainerView.bounds.width, circleContainerView.bounds.height) / 2) - 4
        
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: .pi * 3 / 2,
            clockwise: true
        )
        
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }
    
    private func updateProgress(animated: Bool = true) {
        guard totalDuration > 0 else {
            progressLayer.strokeEnd = 0
            previousProgress = 0
            return
        }
        
        let currentProgress = max(0, min(1, viewModel.remainingTime / totalDuration))
        let targetValue = CGFloat(currentProgress)
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = previousProgress
            animation.toValue = targetValue
            animation.duration = 0.25
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(animation, forKey: "progressAnimation")
        }
        
        progressLayer.strokeEnd = targetValue
        previousProgress = targetValue
    }
    
    private func animateButtonTap(_ view: UIView) {
        UIView.animate(withDuration: 0.08, animations: {
            view.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                view.transform = .identity
            }
        }
    }
    
    private func bindViewModel() {
        viewModel.onTick = { [weak self] timeText in
            self?.remainTimeLabel.text = timeText
            self?.updateProgress(animated: true)
        }
        
        viewModel.onEndTimeTextUpdated = { [weak self] endText in
            self?.endTimeLabel.text = endText
        }
        
        viewModel.onSelectedDurationChanged = { [weak self] title in
            self?.titleLabel.text = title
        }
        
        viewModel.onSelectedSoundChanged = { [weak self] soundText in
            self?.bottomInfoValueLabel.text = soundText
        }
        
        viewModel.onLabelChanged = { [weak self] text in
            self?.topInfoValueLabel.text = text
        }
        
        viewModel.onStateChanged = { [weak self] isRunning in
            self?.pauseButton.setTitle(isRunning ? "일시 정지" : "재개", for: .normal)
        }
        
        viewModel.onTimerFinished = { [weak self] in
            self?.playAlarmSound()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc
    private func cancelButtonTapped() {
        animateButtonTap(cancelButton)
        audioPlayer?.stop()
        viewModel.cancelTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc
    private func pauseButtonTapped() {
        animateButtonTap(pauseButton)
        
        if viewModel.isRunning {
            viewModel.pauseTimer()
        } else {
            viewModel.resumeTimer()
        }
    }
    
    @objc
    private func topRowTapped() {
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
    
    @objc
    private func bottomRowTapped() {
        let vc = TimerSoundViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func playAlarmSound() {
        let fileName = viewModel.soundFileName(for: viewModel.selectedSound)
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") else {
            print("파일 없음: \(fileName).wav")
            return
        }
        
        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.currentTime = 0
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.audioPlayer?.stop()
            }
        } catch {
            print("재생 실패: \(error)")
        }
    }
}
