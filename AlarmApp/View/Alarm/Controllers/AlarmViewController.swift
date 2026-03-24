//
//  AlarmViewController.swift
//  AlarmApp
//
//  Created by 이정인 on 3/20/26.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

// MARK: - 알람 목록 화면 구현
final class AlarmViewController: UIViewController {
    
    // MARK: - 속성
    private let viewModel = AlarmViewModel.shared
    private let disposeBag = DisposeBag()
    private let isEditingMode = BehaviorRelay<Bool>(value: false)
    
    // MARK: - UI 설정
    private let editButton = UIButton().then {
        $0.setTitle("편집", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(red: 255/255, green: 94/255, blue: 0/255, alpha: 1.0)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 20)
        $0.layer.cornerRadius = 20
    }
    
    private let plusButton = UIButton().then {
        $0.setTitle("+", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(red: 255/255, green: 94/255, blue: 0/255, alpha: 1.0)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 20)
        $0.layer.cornerRadius = 20
    }
    
    private let alarmLabel = UILabel().then {
        $0.text = "정인이네 알람"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 24, weight: .heavy)
    }
    
    private let underlineView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let etcLabel = UILabel().then {
        $0.text = "기타"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 20, weight: .heavy)
    }
    
    private let etcUnderlineView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .black
        $0.separatorStyle = .none
        $0.rowHeight = 100
        $0.register(AlarmCell.self, forCellReuseIdentifier: AlarmCell.id)
    }
    
    // MARK: - 생명 주기
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        viewModel.loadAlarms()
    }
    
    // MARK: - UI 구성
    private func configureUI() {
        view.backgroundColor = .black
        
        [
            editButton,
            plusButton,
            alarmLabel,
            underlineView,
            etcLabel,
            etcUnderlineView,
            tableView
        ].forEach { view.addSubview($0) }
        
        editButton.snp.makeConstraints {
            $0.width.equalTo(60)
            $0.height.equalTo(40)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.leading.equalToSuperview().offset(10)
        }
        
        plusButton.snp.makeConstraints {
            $0.size.equalTo(40)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        alarmLabel.snp.makeConstraints {
            $0.top.equalTo(editButton.snp.bottom).offset(50)
            $0.leading.equalToSuperview().offset(10)
        }
        
        underlineView.snp.makeConstraints {
            $0.top.equalTo(alarmLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges).inset(10)
            $0.height.equalTo(1)
        }
        
        etcLabel.snp.makeConstraints {
            $0.top.equalTo(underlineView.snp.bottom).offset(70)
            $0.leading.equalToSuperview().offset(10)
        }
        
        etcUnderlineView.snp.makeConstraints {
            $0.top.equalTo(etcLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges).inset(10)
            $0.height.equalTo(1)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(etcUnderlineView.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
    }
    
    // MARK: - Rx 바인딩
    private func bind() {
        
        editButton.rx.tap
            .withLatestFrom(isEditingMode)
            .map { !$0 }
            .bind(to: isEditingMode)
            .disposed(by: disposeBag)
        
        isEditingMode
            .map { $0 ? "완료" : "편집" }
            .bind(to: editButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        plusButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let plusViewController = AlarmPlusViewController()
                self?.navigationController?.pushViewController(plusViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            viewModel.alarms.asObservable(),
            isEditingMode.asObservable()
        )
        .map { alarms, isEditing in
            alarms.map { ($0, isEditing) }
        }
        .bind(to: tableView.rx.items(cellIdentifier: AlarmCell.id, cellType: AlarmCell.self)) { [weak self] row, element, cell in
            let alarm = element.0
            let isEditing = element.1
            
            cell.configure(with: alarm, isEditing: isEditing)
            
            cell.onSwitchChanged = { isOn in
                self?.viewModel.toggleAlarm(id: alarm.id, isOn: isOn)
            }
            
            cell.onDeleteTapped = { [weak self] in
                self?.viewModel.deleteAlarm(id: alarm.id)
            }
        }
        .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .withLatestFrom(isEditingMode) { ($0, $1) }
            .filter { _, isEditing in isEditing }
            .map { $0.0 }
            .subscribe(onNext: { [weak self] indexPath in
                guard let self else { return }
                
                let selectedAlarm = self.viewModel.alarms.value[indexPath.row]
                let editViewController = AlarmEditViewController(alarm: selectedAlarm)
                self.navigationController?.pushViewController(editViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
    }

}
