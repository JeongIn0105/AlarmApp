//
//  AlarmViewController.swift
//  AlarmApp
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

// MARK: - 알람 목록 화면 구현
final class AlarmViewController: UIViewController {
    
    // MARK: - 속성
    
    // 알람 데이터를 관리하는 ViewModel (싱글톤)
    private let viewModel = AlarmViewModel.shared
    
    // RxSwift 메모리 관리용
    private let disposeBag = DisposeBag()
    
    // 편집 모드 여부 (true = 편집, false = 일반)
    private let isEditingMode = BehaviorRelay<Bool>(value: false)
    
    // MARK: - UI 설정
    
    // 편집 버튼 (편집 / 완료 토글)
    private let editButton = UIButton().then {
        $0.setTitle("편집", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(red: 255/255, green: 94/255, blue: 0/255, alpha: 1.0)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 20)
        $0.layer.cornerRadius = 20
    }
    
    // 알람 추가 버튼 (+)
    private let plusButton = UIButton().then {
        $0.setTitle("+", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(red: 255/255, green: 94/255, blue: 0/255, alpha: 1.0)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 20)
        $0.layer.cornerRadius = 20
    }
    
    // 상단 타이틀 라벨
    private let alarmLabel = UILabel().then {
        $0.text = "정인이네 알람"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 24, weight: .heavy)
    }
    
    // 구분선
    private let underlineView = UIView().then {
        $0.backgroundColor = .white
    }
    
    // 섹션 제목 ("기타")
    private let etcLabel = UILabel().then {
        $0.text = "기타"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 20, weight: .heavy)
    }
    
    // 섹션 구분선
    private let etcUnderlineView = UIView().then {
        $0.backgroundColor = .white
    }
    
    // 알람 리스트 테이블뷰
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .black
        $0.separatorStyle = .none
        $0.rowHeight = 100
        $0.register(AlarmCell.self, forCellReuseIdentifier: AlarmCell.id)
    }
    
    // MARK: - 생명 주기
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()   // UI 배치
        bind()          // Rx 바인딩
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 네비게이션 바 숨김
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // 알람 데이터 로드
        viewModel.loadAlarms()
    }
    
    // MARK: - UI 구성
    
    private func configureUI() {
        view.backgroundColor = .black
        
        // UI 요소 추가
        [
            editButton,
            plusButton,
            alarmLabel,
            underlineView,
            etcLabel,
            etcUnderlineView,
            tableView
        ].forEach { view.addSubview($0) }
        
        // 편집 버튼 위치
        editButton.snp.makeConstraints {
            $0.width.equalTo(60)
            $0.height.equalTo(40)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.leading.equalToSuperview().offset(10)
        }
        
        // + 버튼 위치
        plusButton.snp.makeConstraints {
            $0.size.equalTo(40)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        // 타이틀 위치
        alarmLabel.snp.makeConstraints {
            $0.top.equalTo(editButton.snp.bottom).offset(50)
            $0.leading.equalToSuperview().offset(10)
        }
        
        // 상단 구분선
        underlineView.snp.makeConstraints {
            $0.top.equalTo(alarmLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges).inset(10)
            $0.height.equalTo(1)
        }
        
        // "기타" 라벨 위치
        etcLabel.snp.makeConstraints {
            $0.top.equalTo(underlineView.snp.bottom).offset(70)
            $0.leading.equalToSuperview().offset(10)
        }
        
        // "기타" 구분선
        etcUnderlineView.snp.makeConstraints {
            $0.top.equalTo(etcLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges).inset(10)
            $0.height.equalTo(1)
        }
        
        // 테이블뷰 위치
        tableView.snp.makeConstraints {
            $0.top.equalTo(etcUnderlineView.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - 휴지통 버튼용 Alert
    
    // 휴지통 버튼 눌렀을 때만 호출됨
    private func showDeleteAlert(alarmID: UUID) {
        
        // Alert 생성
        let alert = UIAlertController(
            title: nil,
            message: "알람 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        // "네" → 실제 삭제
        let yesAction = UIAlertAction(title: "네", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteAlarm(id: alarmID)
        }
        
        // "아니요" → 취소
        let noAction = UIAlertAction(title: "아니요", style: .cancel)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        // Alert 표시
        present(alert, animated: true)
    }
    
    // MARK: - 스와이프용 즉시 삭제
    
    // 스와이프에서는 Alert 없이 바로 삭제
    private func deleteAlarmImmediately(alarmID: UUID) {
        viewModel.deleteAlarm(id: alarmID)
    }
    
    // MARK: - Rx 바인딩
    
    private func bind() {
        
        // 스와이프 기능을 위해 delegate 연결
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // 편집 버튼 클릭 → true/false 토글
        editButton.rx.tap
            .withLatestFrom(isEditingMode)
            .map { !$0 }
            .bind(to: isEditingMode)
            .disposed(by: disposeBag)
        
        // 버튼 텍스트 변경 (편집 ↔ 완료)
        isEditingMode
            .map { $0 ? "완료" : "편집" }
            .bind(to: editButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        // + 버튼 클릭 → 추가 화면 이동
        plusButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let plusViewController = AlarmPlusViewController()
                self?.navigationController?.pushViewController(plusViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 알람 데이터 + 편집모드 같이 바인딩
        Observable.combineLatest(
            viewModel.alarms.asObservable(),
            isEditingMode.asObservable()
        )
        .map { alarms, isEditing in
            alarms.map { ($0, isEditing) }
        }
        .bind(to: tableView.rx.items(cellIdentifier: AlarmCell.id, cellType: AlarmCell.self)) { [weak self] row, element, cell in
            
            guard let self else { return }
            
            let alarm = element.0
            let isEditing = element.1
            
            // 셀 UI 구성
            cell.configure(with: alarm, isEditing: isEditing)
            
            // 스위치 ON/OFF 변경
            cell.onSwitchChanged = { isOn in
                self.viewModel.toggleAlarm(id: alarm.id, isOn: isOn)
            }
            
            // 휴지통 버튼 → Alert 표시
            cell.onDeleteTapped = { [weak self] in
                self?.showDeleteAlert(alarmID: alarm.id)
            }
        }
        .disposed(by: disposeBag)
        
        // 셀 선택 → 편집 화면 이동
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self else { return }
                
                self.tableView.deselectRow(at: indexPath, animated: true)
                
                let selectedAlarm = self.viewModel.alarms.value[indexPath.row]
                let editViewController = AlarmEditViewController(alarm: selectedAlarm)
                self.navigationController?.pushViewController(editViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - 테이블 뷰 Delegate 설정
extension AlarmViewController: UITableViewDelegate {
    
    // 편집 모드일 때만 스와이프 허용
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEditingMode.value
    }
    
    // 스와이프 삭제 구현
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        // 편집 모드 아닐 때는 스와이프 막음
        guard isEditingMode.value else { return nil }
        
        let selectedAlarm = viewModel.alarms.value[indexPath.row]
        
        // 삭제 액션 생성
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            
            // Alert 없이 바로 삭제
            self?.deleteAlarmImmediately(alarmID: selectedAlarm.id)
            
            completion(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        // 끝까지 밀면 바로 삭제
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}
