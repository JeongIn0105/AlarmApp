//
//  TimerViewController.swift
//  AlarmApp
//
//  Created by 이정인 on 3/23/26.
//

import UIKit
import SnapKit
import Then
import RxSwift

// MARK: - 타이머 메인 화면
// 타이머 전체 흐름을 담당 (시간 설정, 시작, 초기화, 최근 항목, 화면 이동)
final class TimerViewController: UIViewController {
    
    // 타이머 상태 및 데이터 관리 ViewModel
    private let viewModel = TimerViewModel()
    
    // Rx 메모리 관리
    private let disposeBag = DisposeBag()
    
    // 중복 화면 push 방지 플래그
    private var isPushingTimerStart = false
    
    // 상단 타이틀
    private let timerLabel = UILabel().then {
        $0.text = "타이머"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 28, weight: .heavy)
    }
    
    // 시간 선택 Picker 화면
    private let pickerViewController = TimePickerViewController()
    
    // 최근 항목 화면 (ViewModel 공유)
    private lazy var recentViewController = TimeRecentViewController(viewModel: viewModel)
    
    // 초기화 버튼
    private let cancelButton = UIButton().then {
        $0.setTitle("초기화", for: .normal)
        $0.setTitleColor(UIColor(red: 1.0, green: 94/255, blue: 0, alpha: 1.0), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        // 어두운 배경
        $0.backgroundColor = UIColor(red: 95/255, green: 19/255, blue: 0, alpha: 1.0)
        $0.layer.cornerRadius = 35
        $0.clipsToBounds = true
    }
    
    // 시작 버튼
    private let startButton = UIButton().then {
        $0.setTitle("시작", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        // 초록색 배경
        $0.backgroundColor = UIColor.systemGreen
        $0.layer.cornerRadius = 35
        $0.clipsToBounds = true
    }
    
    // MARK: - 생명 주기
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()      // UI 구성
        embedChildren()    // 자식 ViewController 연결
        bind()             // 이벤트 바인딩
        
        // 초기 타이머 값 설정 (7분)
        pickerViewController.setTime(hour: 0, minute: 7, second: 0)
        
        // ViewModel에도 동일하게 반영
        viewModel.updateSelectedDuration(pickerViewController.selectedDuration)
        
        // 초기 UI 동기화
        recentViewController.updateLabelText(viewModel.labelText)
        recentViewController.updateSoundText(viewModel.displaySoundName)
    }
    
    // 화면 나타날 때 네비게이션 숨김
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // 화면 표시 완료 후 push 플래그 초기화
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isPushingTimerStart = false
    }
    
    // MARK: - UI 구성
    
    private func configureUI() {
        view.backgroundColor = .black
        
        // 뷰 추가
        [
            timerLabel,
            cancelButton,
            startButton
        ].forEach { view.addSubview($0) }
        
        // 타이틀 위치
        timerLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        // 초기화 버튼 위치
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.width.height.equalTo(70)
        }
        
        // 시작 버튼 위치
        startButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.equalTo(70)
        }
    }
    
    // MARK: - 자식 ViewController 연결
    
    private func embedChildren() {
        
        // 시간 Picker 추가
        addChild(pickerViewController)
        view.addSubview(pickerViewController.view)
        pickerViewController.didMove(toParent: self)
        
        // 최근 항목 화면 추가
        addChild(recentViewController)
        view.addSubview(recentViewController.view)
        recentViewController.didMove(toParent: self)
        
        // Picker 위치
        pickerViewController.view.snp.makeConstraints {
            $0.top.equalTo(timerLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        // 버튼 위치
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(pickerViewController.view.snp.bottom).offset(20)
        }
        
        startButton.snp.makeConstraints {
            $0.top.equalTo(pickerViewController.view.snp.bottom).offset(20)
        }
        
        // 최근 항목 위치
        recentViewController.view.snp.makeConstraints {
            $0.top.equalTo(cancelButton.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - 바인딩
    
    private func bind() {
        
        // Picker 시간 변경 시 ViewModel 업데이트
        pickerViewController.onTimeChanged = { [weak self] duration in
            self?.viewModel.updateSelectedDuration(duration)
        }
        
        // 최근 항목 클릭 시 타이머 시작 화면으로 이동
        recentViewController.onRecentItemSelected = { [weak self] index in
            guard let self else { return }
            
            self.viewModel.configureMainTimerFromRecent(at: index)
            self.moveToTimerStart()
        }
        
        // 레이블 클릭
        recentViewController.onOpenLabel = { [weak self] in
            self?.showLabelAlert()
        }
        
        // 사운드 클릭 → 사운드 설정 화면 이동
        recentViewController.onOpenSound = { [weak self] in
            guard let self else { return }
            
            let vc = TimerSoundViewController(viewModel: self.viewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        // 버튼 액션 연결
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        
        // 타이머 종료 시 사운드 재생
        viewModel.onTimerFinished = { [weak self] in
            guard let self else { return }
            TimerSoundPlayer.shared.playSound(named: self.viewModel.currentSoundFileName)
        }
        
        // 최근 타이머 종료 시 사운드 재생
        viewModel.onRecentTimerFinished = { [weak self] in
            guard let self else { return }
            TimerSoundPlayer.shared.playSound(named: self.viewModel.currentSoundFileName)
        }
        
        // 사운드 변경 시 UI 반영
        viewModel.onSelectedSoundChanged = { [weak self] soundText in
            self?.recentViewController.updateSoundText(soundText)
        }
        
        // 레이블 변경 시 UI 반영
        viewModel.onLabelChanged = { [weak self] text in
            self?.recentViewController.updateLabelText(text)
        }
    }
    
    // MARK: - 버튼 액션
    
    // 초기화 버튼 클릭
    @objc
    private func cancelTapped() {
        
        // Picker 시간 초기화
        pickerViewController.setTime(hour: 0, minute: 0, second: 0)
        
        // ViewModel 초기화
        viewModel.updateSelectedDuration(0)
        
        // 사운드 정지
        TimerSoundPlayer.shared.stopSound()
    }
    
    // 시작 버튼 클릭
    @objc
    private func startTapped() {
        
        let duration = pickerViewController.selectedDuration
        
        // 0초면 실행 안 함
        guard duration > 0 else { return }
        
        // ViewModel에 시간 설정
        viewModel.updateSelectedDuration(duration)
        
        // 타이머 시작
        viewModel.startTimer()
        
        // 실행 화면 이동
        moveToTimerStart()
    }
    
    // MARK: - 타이머 실행 화면 이동
    
    private func moveToTimerStart() {
        
        // 중복 push 방지
        guard !isPushingTimerStart else { return }
        isPushingTimerStart = true
        
        let startVC = TimerStartViewController(viewModel: viewModel)
        
        // 탭바 유지
        startVC.hidesBottomBarWhenPushed = false
        
        navigationController?.pushViewController(startVC, animated: true)
    }
    
    // MARK: - 레이블 입력 Alert
    
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
