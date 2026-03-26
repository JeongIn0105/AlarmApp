//
//  TimerViewController.swift
//  AlarmApp
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class TimerViewController: UIViewController {
    
    private let viewModel = TimerViewModel()
    private let disposeBag = DisposeBag()
    
    private let timerLabel = UILabel().then {
        $0.text = "타이머"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 28, weight: .heavy)
    }
    
    private let datePicker = UIDatePicker().then {
        $0.datePickerMode = .countDownTimer
        $0.preferredDatePickerStyle = .wheels
        $0.locale = Locale(identifier: "ko_KR")
        $0.tintColor = .white
        $0.setValue(UIColor.white, forKey: "textColor")
        $0.backgroundColor = .clear
        $0.overrideUserInterfaceStyle = .dark
    }
    
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
    
    private let recentTitleLabel = UILabel().then {
        $0.text = "최근 항목"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 20, weight: .heavy)
    }
    
    private let recentDividerLine = UIView().then {
        $0.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
    }
    
    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .black
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = true
        $0.alwaysBounceVertical = true
        $0.rowHeight = 72
        $0.register(TimerCell.self, forCellReuseIdentifier: TimerCell.id)
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
        
        datePicker.countDownDuration = 420
        viewModel.updateSelectedDuration(datePicker.countDownDuration)
        topInfoValueLabel.text = viewModel.labelText
        bottomInfoValueLabel.text = viewModel.displaySoundName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func configureUI() {
        view.backgroundColor = .black
        
        [
            timerLabel,
            datePicker,
            cancelButton,
            startButton,
            infoContainerView,
            recentTitleLabel,
            recentDividerLine,
            tableView
        ].forEach { view.addSubview($0) }
        
        [
            topInfoTitleLabel,
            topInfoValueLabel,
            dividerLine,
            bottomInfoTitleLabel,
            bottomInfoValueLabel,
            topRowButton,
            bottomRowButton
        ].forEach { infoContainerView.addSubview($0) }
        
        timerLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(timerLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.top.equalTo(datePicker.snp.bottom).offset(20)
            $0.width.height.equalTo(70)
        }
        
        startButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-30)
            $0.top.equalTo(datePicker.snp.bottom).offset(20)
            $0.width.height.equalTo(70)
        }
        
        infoContainerView.snp.makeConstraints {
            $0.top.equalTo(cancelButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(116)
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
        
        recentTitleLabel.snp.makeConstraints {
            $0.top.equalTo(infoContainerView.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(20)
        }
        
        recentDividerLine.snp.makeConstraints {
            $0.top.equalTo(recentTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(recentDividerLine.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
    }
    
    private func bind() {
        viewModel.recentItemsRelay
            .bind(to: tableView.rx.items(
                cellIdentifier: TimerCell.id,
                cellType: TimerCell.self
            )) { [weak self] index, item, cell in
                guard let self else { return }
                
                cell.configure(item: item)
                
                cell.onTapPlay = { [weak self] in
                    guard let self else { return }
                    self.animateButtonTap(cell)
                    self.viewModel.startRecentTimer(at: index)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
                        guard let self else { return }
                        let startVC = TimerStartViewController(viewModel: self.viewModel)
                        startVC.hidesBottomBarWhenPushed = false
                        self.navigationController?.pushViewController(startVC, animated: true)
                    }
                }
                
                cell.onTapDelete = { [weak self, weak cell] in
                    guard let self, let cell else { return }
                    cell.animateDelete {
                        self.viewModel.deleteRecentItem(at: index)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        datePicker.rx.controlEvent(.valueChanged)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.viewModel.updateSelectedDuration(owner.datePicker.countDownDuration)
            })
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.animateButtonTap(owner.cancelButton)
                owner.datePicker.countDownDuration = 0
                owner.viewModel.updateSelectedDuration(0)
            })
            .disposed(by: disposeBag)
        
        startButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.animateButtonTap(owner.startButton)
                guard owner.datePicker.countDownDuration > 0 else { return }
                
                owner.viewModel.updateSelectedDuration(owner.datePicker.countDownDuration)
                owner.viewModel.startTimer()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak owner] in
                    guard let owner else { return }
                    let startVC = TimerStartViewController(viewModel: owner.viewModel)
                    startVC.hidesBottomBarWhenPushed = false
                    owner.navigationController?.pushViewController(startVC, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        topRowButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.showLabelAlert()
            })
            .disposed(by: disposeBag)
        
        bottomRowButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                let vc = TimerSoundViewController(viewModel: owner.viewModel)
                owner.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.onSelectedSoundChanged = { [weak self] soundText in
            self?.bottomInfoValueLabel.text = soundText
        }
        
        viewModel.onLabelChanged = { [weak self] text in
            self?.topInfoValueLabel.text = text
        }
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
