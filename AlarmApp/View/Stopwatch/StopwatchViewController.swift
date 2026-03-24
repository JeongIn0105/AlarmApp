//
//  StopwatchViewController.swift
//  AlarmApp
//
//  Created by 이정인 on 3/20/26.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

// MARK: - 스톱워치 화면 구현
final class StopwatchViewController: UIViewController {
    
    // MARK: - 속성
    private let viewModel = StopwatchViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI 구성 요소
    // 시간 표시 라벨
    private let timeLabel = UILabel().then {
        $0.text = "00:00.00"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 64, weight: .bold)
        $0.textAlignment = .center
    }
    
    // 왼쪽 버튼 (랩 / 재설정)
    private let leftButton = UIButton().then {
        $0.setTitle("랩", for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        $0.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        $0.layer.cornerRadius = 45
        $0.clipsToBounds = true
    }
    
    // 오른쪽 버튼 (시작 / 중단)
    private let rightButton = UIButton().then {
        $0.setTitle("시작", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        $0.backgroundColor = UIColor.systemGreen
        $0.layer.cornerRadius = 45
        $0.clipsToBounds = true
    }
    
    // 구분선
    private let dividerView = UIView().then {
        $0.backgroundColor = UIColor(white: 0.7, alpha: 1.0)
    }
    
    // 랩 리스트 테이블뷰
    private let lapTableView = UITableView().then {
        $0.backgroundColor = .black
        $0.separatorColor = UIColor(white: 0.3, alpha: 1.0)
        $0.rowHeight = 72
        $0.showsVerticalScrollIndicator = true
        $0.register(StopwatchCell.self, forCellReuseIdentifier: StopwatchCell.id)
        $0.isScrollEnabled = true
        $0.alwaysBounceVertical = true
        $0.bounces = true
    }
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bindActions()
        bindViewModel()
        updateUI(for: viewModel.state)
    }
    
    // MARK: - UI 설정
    private func configureUI() {
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(timeLabel)
        view.addSubview(leftButton)
        view.addSubview(rightButton)
        view.addSubview(dividerView)
        view.addSubview(lapTableView)
        
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(90)
            $0.centerX.equalToSuperview()
        }
        
        leftButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.top.equalTo(timeLabel.snp.bottom).offset(70)
            $0.width.height.equalTo(90)
        }
        
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-32)
            $0.top.equalTo(timeLabel.snp.bottom).offset(70)
            $0.width.height.equalTo(90)
        }
        
        dividerView.snp.makeConstraints {
            $0.top.equalTo(leftButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(1)
        }
        
        lapTableView.snp.makeConstraints {
            $0.top.equalTo(dividerView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-120)
        }
        
        // 마지막 셀이 하단 탭 바에 가리지 않도록 여백 추가
        lapTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        lapTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    // MARK: - 버튼 이벤트 바인딩
    private func bindActions() {
        leftButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                
                switch self.viewModel.state {
                case .initial:
                    break
                case .running:
                    self.viewModel.recordLap()
                case .paused:
                    self.viewModel.reset()
                }
            }
            .disposed(by: disposeBag)
        
        rightButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                
                switch self.viewModel.state {
                case .initial, .paused:
                    self.viewModel.start()
                case .running:
                    self.viewModel.stop()
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - ViewModel 바인딩
    private func bindViewModel() {
        viewModel.timeText
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.stateRelay
            .bind { [weak self] state in
                self?.updateUI(for: state)
            }
            .disposed(by: disposeBag)
        
        viewModel.laps
            .bind(to: lapTableView.rx.items(
                cellIdentifier: StopwatchCell.id,
                cellType: StopwatchCell.self
            )) { [weak self] _, lap, cell in
                guard let self else { return }
                
                cell.configure(
                    lapNumber: lap.number,
                    timeText: self.viewModel.formattedTime(lap.time)
                )
            }
            .disposed(by: disposeBag)
        
        viewModel.stateRelay
            .subscribe(onNext: { [weak self] state in
                self?.updateUI(for: state)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 상태에 따른 UI 변경
    private func updateUI(for state: StopwatchViewModel.StopwatchState) {
        switch state {
        case .initial:
            leftButton.setTitle("랩", for: .normal)
            leftButton.setTitleColor(.lightGray, for: .normal)
            leftButton.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
            
            rightButton.setTitle("시작", for: .normal)
            rightButton.setTitleColor(.black, for: .normal)
            rightButton.backgroundColor = .systemGreen
            
        case .running:
            leftButton.setTitle("랩", for: .normal)
            leftButton.setTitleColor(.lightGray, for: .normal)
            leftButton.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
            
            rightButton.setTitle("중단", for: .normal)
            rightButton.setTitleColor(.red, for: .normal)
            rightButton.backgroundColor = UIColor(red: 0.55, green: 0.0, blue: 0.0, alpha: 1.0)
            
        case .paused:
            leftButton.setTitle("재설정", for: .normal)
            leftButton.setTitleColor(.lightGray, for: .normal)
            leftButton.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
            
            rightButton.setTitle("시작", for: .normal)
            rightButton.setTitleColor(.black, for: .normal)
            rightButton.backgroundColor = .systemGreen
        }
    }
    
}
