//
//  TimeRecentViewController.swift
//  AlarmApp
//
//  Created by 이정인 on 3/23/26.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

// MARK: - 타이머 최근 항목 화면 구현
final class TimeRecentViewController: UIViewController {
    
    // 최근 항목 클릭 시 외부로 index 전달
    var onRecentItemSelected: ((Int) -> Void)?
    
    // "레이블" 클릭 시 외부 화면 열기
    var onOpenLabel: (() -> Void)?
    
    // "타이머 종료 시" 클릭 시 외부 화면 열기
    var onOpenSound: (() -> Void)?
    
    // 타이머 데이터 관리 ViewModel
    private let viewModel: TimerViewModel
    
    // Rx 메모리 관리
    private let disposeBag = DisposeBag()
    
    // 상단 정보 영역 컨테이너
    private let infoContainerView = UIView().then {
        $0.backgroundColor = UIColor(white: 0.22, alpha: 1.0)
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    
    // "레이블" 타이틀
    private let topInfoTitleLabel = UILabel().then {
        $0.text = "레이블"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 17, weight: .bold)
    }
    
    // 선택된 레이블 값
    private let topInfoValueLabel = UILabel().then {
        $0.text = "타이머"
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 17, weight: .medium)
        $0.textAlignment = .right
    }
    
    // 구분선
    private let dividerLine = UIView().then {
        $0.backgroundColor = UIColor(white: 0.32, alpha: 1.0)
    }
    
    // "타이머 종료 시" 타이틀
    private let bottomInfoTitleLabel = UILabel().then {
        $0.text = "타이머 종료 시"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 17, weight: .bold)
    }
    
    // 선택된 사운드 값
    private let bottomInfoValueLabel = UILabel().then {
        $0.text = "레디얼 >"
        $0.textColor = .lightGray
        $0.font = .systemFont(ofSize: 17, weight: .medium)
        $0.textAlignment = .right
    }
    
    // 상단 row 전체 클릭 영역 버튼
    private let topRowButton = UIButton(type: .system)
    
    // 하단 row 전체 클릭 영역 버튼
    private let bottomRowButton = UIButton(type: .system)
    
    // "최근 항목" 타이틀
    private let recentTitleLabel = UILabel().then {
        $0.text = "최근 항목"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 20, weight: .heavy)
    }
    
    // 최근 항목 구분선
    private let recentDividerLine = UIView().then {
        $0.backgroundColor = UIColor(white: 1.0, alpha: 0.12)
    }
    
    // 최근 항목 리스트 테이블뷰
    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .black
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.rowHeight = 84
        $0.register(TimerCell.self, forCellReuseIdentifier: TimerCell.id)
        
        // 상하 여백
        $0.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 24, right: 0)
    }
    
    // MARK: - 초기화
    
    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    // 스토리보드 사용 안함
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 생명 주기
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()         // UI 구성
        configureTableView()  // 테이블뷰 설정
        bind()                // Rx 바인딩
    }
    
    // MARK: - 외부 값 업데이트
    
    // 레이블 텍스트 변경
    func updateLabelText(_ text: String) {
        topInfoValueLabel.text = text
    }
    
    // 사운드 텍스트 변경
    func updateSoundText(_ text: String) {
        bottomInfoValueLabel.text = text
    }
    
    // MARK: - UI 구성
    
    private func configureUI() {
        view.backgroundColor = .black
        
        // 루트 뷰에 추가
        [
            infoContainerView,
            recentTitleLabel,
            recentDividerLine,
            tableView
        ].forEach { view.addSubview($0) }
        
        // 상단 정보 영역 내부 구성
        [
            topInfoTitleLabel,
            topInfoValueLabel,
            dividerLine,
            bottomInfoTitleLabel,
            bottomInfoValueLabel,
            topRowButton,
            bottomRowButton
        ].forEach { infoContainerView.addSubview($0) }
        
        // 상단 컨테이너
        infoContainerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(116)
        }
        
        // "레이블" 위치
        topInfoTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(18)
        }
        
        // 레이블 값 위치
        topInfoValueLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(topInfoTitleLabel)
        }
        
        // 구분선
        dividerLine.snp.makeConstraints {
            $0.top.equalTo(topInfoTitleLabel.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        // "타이머 종료 시" 위치
        bottomInfoTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(dividerLine.snp.bottom).offset(18)
        }
        
        // 사운드 값 위치
        bottomInfoValueLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(bottomInfoTitleLabel)
        }
        
        // 상단 영역 전체 클릭 가능하도록 버튼 덮기
        topRowButton.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(dividerLine.snp.top)
        }
        
        // 하단 영역 전체 클릭 버튼
        bottomRowButton.snp.makeConstraints {
            $0.top.equalTo(dividerLine.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        // "최근 항목" 위치
        recentTitleLabel.snp.makeConstraints {
            $0.top.equalTo(infoContainerView.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(20)
        }
        
        // 최근 항목 구분선
        recentDividerLine.snp.makeConstraints {
            $0.top.equalTo(recentTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        // 테이블뷰 위치
        tableView.snp.makeConstraints {
            $0.top.equalTo(recentDividerLine.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
    
    // MARK: - 테이블뷰 설정
    
    private func configureTableView() {
        // 스와이프 기능 사용을 위한 delegate 연결
        tableView.delegate = self
    }
    
    // MARK: - Rx 바인딩
    
    private func bind() {
        
        // 상단 클릭 이벤트 연결
        topRowButton.addTarget(self, action: #selector(labelTapped), for: .touchUpInside)
        bottomRowButton.addTarget(self, action: #selector(soundTapped), for: .touchUpInside)
        
        // 최근 항목 데이터 바인딩
        viewModel.recentItemsRelay
            .bind(to: tableView.rx.items(
                cellIdentifier: TimerCell.id,
                cellType: TimerCell.self
            )) { [weak self] index, item, cell in
                
                guard let self else { return }
                
                // 셀 데이터 설정
                cell.configure(item: item)
                
                // 재생 버튼 클릭
                cell.onTapPlay = { [weak self] in
                    self?.viewModel.toggleRecentItemRunning(at: index)
                }
                
                // 초기화 버튼 클릭 (리셋)
                cell.onTapDelete = { [weak self] in
                    self?.viewModel.resetRecentItem(at: index)
                }
            }
            .disposed(by: disposeBag)
        
        // 셀 클릭 이벤트
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                
                // 선택 효과 제거
                self?.tableView.deselectRow(at: indexPath, animated: true)
                
                // 외부로 선택된 index 전달
                self?.onRecentItemSelected?(indexPath.row)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 버튼 액션
    
    // 레이블 클릭
    @objc
    private func labelTapped() {
        onOpenLabel?()
    }
    
    // 사운드 클릭
    @objc
    private func soundTapped() {
        onOpenSound?()
    }
}

// MARK: - UITableViewDelegate

extension TimeRecentViewController: UITableViewDelegate {
    
    // 스와이프 삭제 기능
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        // 삭제 액션 생성
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            
            // 최근 항목 삭제
            self?.viewModel.deleteRecentItem(at: indexPath.row)
            
            completion(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        // 끝까지 밀면 바로 삭제
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}
