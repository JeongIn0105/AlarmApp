//
//  TimeRecentViewController.swift
//  AlarmApp
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

// MARK: - 타이머 최근 항목 구현
final class TimeRecentViewController: UIViewController {
    
    var onRecentItemSelected: ((Int) -> Void)?
    var onOpenLabel: (() -> Void)?
    var onOpenSound: (() -> Void)?
    
    private let viewModel: TimerViewModel
    private let disposeBag = DisposeBag()
    
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
        $0.backgroundColor = UIColor(white: 1.0, alpha: 0.12)
    }
    
    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .black
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.rowHeight = 84
        $0.register(TimerCell.self, forCellReuseIdentifier: TimerCell.id)
        $0.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 24, right: 0)
    }
    
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
        bind()
    }
    
    func updateLabelText(_ text: String) {
        topInfoValueLabel.text = text
    }
    
    func updateSoundText(_ text: String) {
        bottomInfoValueLabel.text = text
    }
    
    private func configureUI() {
        view.backgroundColor = .black
        
        [
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
        
        infoContainerView.snp.makeConstraints {
            $0.top.equalToSuperview()
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
            $0.bottom.equalToSuperview()
        }
    }
    
    private func bind() {
        topRowButton.addTarget(self, action: #selector(labelTapped), for: .touchUpInside)
        bottomRowButton.addTarget(self, action: #selector(soundTapped), for: .touchUpInside)
        
        viewModel.recentItemsRelay
            .bind(to: tableView.rx.items(
                cellIdentifier: TimerCell.id,
                cellType: TimerCell.self
            )) { [weak self] index, item, cell in
                guard let self else { return }
                
                cell.configure(item: item)
                
                cell.onTapPlay = { [weak self] in
                    self?.viewModel.toggleRecentItemRunning(at: index)
                }
                
                cell.onTapDelete = { [weak self, weak cell] in
                    guard let self, let cell else { return }
                    cell.animateDelete {
                        self.viewModel.deleteRecentItem(at: index)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                self?.onRecentItemSelected?(indexPath.row)
            })
            .disposed(by: disposeBag)
    }
    
    @objc
    private func labelTapped() {
        onOpenLabel?()
    }
    
    @objc
    private func soundTapped() {
        onOpenSound?()
    }
}
