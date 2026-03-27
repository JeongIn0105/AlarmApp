//
//  TimerSoundViewController.swift
//  AlarmApp
//
//  Created by 이정인 on 3/23/26.
//

import UIKit
import SnapKit
import Then

// MARK: - 타이머 사운드 선택 화면
final class TimerSoundViewController: UIViewController {
    
    // 타이머 관련 데이터를 관리하는 ViewModel
    private let viewModel: TimerViewModel
    
    // 선택 가능한 사운드 목록
    private let sounds = [
        "레디얼(기본 설정)",
        "걸음",
        "골짜기",
        "반향",
        "머큐리"
    ]
    
    // 전체 컨테이너 뷰 (가운데 정렬용)
    private let containerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    // 닫기 버튼 (X 버튼)
    private let closeButton = UIButton(type: .system).then {
        
        // 시스템 이미지 설정
        let image = UIImage(systemName: "xmark")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        )
        
        $0.setImage(image, for: .normal)
        $0.tintColor = .white
        
        // 배경 및 스타일
        $0.backgroundColor = UIColor(white: 0.10, alpha: 1.0)
        $0.layer.cornerRadius = 18
        $0.clipsToBounds = true
        
        // 테두리 설정
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(white: 1.0, alpha: 0.08).cgColor
    }
    
    // 상단 제목 라벨
    private let titleLabel = UILabel().then {
        $0.text = "타이머 종료 시"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 28, weight: .bold)
        $0.textAlignment = .center
    }
    
    // 설정 버튼 (확인 버튼 역할)
    private let settingButton = UIButton(type: .system).then {
        $0.setTitle("설정", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        
        // 오렌지 색상 배경
        $0.backgroundColor = UIColor(red: 1.0, green: 149/255, blue: 0, alpha: 1.0)
        $0.layer.cornerRadius = 18
        $0.clipsToBounds = true
    }
    
    // 사운드 리스트를 담는 카드 뷰
    private let cardView = UIView().then {
        $0.backgroundColor = UIColor(white: 0.24, alpha: 1.0)
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
    }
    
    // 사운드 row들을 담는 스택뷰
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    // 각 사운드 row를 저장
    private var rowViews: [SoundRowView] = []
    
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
        
        configureUI()        // UI 구성
        configureRows()      // 사운드 리스트 생성
        updateSelectionUI()  // 선택 상태 반영
    }
    
    // MARK: - UI 구성
    
    private func configureUI() {
        view.backgroundColor = .black
        
        // 루트에 컨테이너 추가
        view.addSubview(containerView)
        
        // 컨테이너 내부 UI 추가
        [
            closeButton,
            titleLabel,
            settingButton,
            cardView
        ].forEach { containerView.addSubview($0) }
        
        // 카드 내부에 스택뷰 추가
        cardView.addSubview(stackView)
        
        // 컨테이너 중앙 정렬
        containerView.snp.makeConstraints {
            $0.centerY.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        
        // 닫기 버튼 위치
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(60)
            $0.centerY.equalTo(titleLabel)
            $0.size.equalTo(36)
        }
        
        // 제목 위치
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        // 설정 버튼 위치
        settingButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-40)
            $0.width.equalTo(60)
            $0.height.equalTo(36)
        }
        
        // 카드뷰 위치
        cardView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview()
        }
        
        // 스택뷰 전체 채우기
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 버튼 액션 연결
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(settingTapped), for: .touchUpInside)
    }
    
    // MARK: - 사운드 리스트 생성
    
    private func configureRows() {
        
        // sounds 배열 순회
        for index in sounds.indices {
            
            let sound = sounds[index]
            
            // 마지막 요소인지 확인 (구분선 처리용)
            let isLast = index == sounds.count - 1
            
            let row = SoundRowView()
            
            // row 설정
            row.configure(title: sound, showsDivider: !isLast)
            
            // row 클릭 시 선택 처리
            row.onTap = { [weak self] in
                guard let self else { return }
                
                // ViewModel에 선택된 사운드 저장
                self.viewModel.updateSelectedSound(sound)
                
                // UI 갱신
                self.updateSelectionUI()
            }
            
            // 스택뷰에 추가
            stackView.addArrangedSubview(row)
            
            // 높이 설정
            row.snp.makeConstraints {
                $0.height.equalTo(72)
            }
            
            // 배열에 저장
            rowViews.append(row)
        }
    }
    
    // MARK: - 선택 상태 UI 업데이트
    
    private func updateSelectionUI() {
        
        for index in rowViews.indices {
            let sound = sounds[index]
            
            // 현재 선택된 사운드인지 확인
            let isSelected = viewModel.selectedSound == sound
            
            // 체크 표시 업데이트
            rowViews[index].setSelected(isSelected)
        }
    }
    
    // MARK: - 버튼 액션
    
    @objc
    private func closeTapped() {
        moveToTimerScreen()
    }
    
    @objc
    private func settingTapped() {
        moveToTimerScreen()
    }
    
    // MARK: - 타이머 화면으로 이동
    
    private func moveToTimerScreen() {
        
        guard let navigationController else { return }
        
        // TimerStartViewController가 있으면 해당 화면으로 이동
        if let startVC = navigationController.viewControllers.first(where: { $0 is TimerStartViewController }) {
            navigationController.popToViewController(startVC, animated: true)
            return
        }
        
        // TimerViewController가 있으면 해당 화면으로 이동
        if let timerVC = navigationController.viewControllers.first(where: { $0 is TimerViewController }) {
            navigationController.popToViewController(timerVC, animated: true)
            return
        }
        
        // 둘 다 없으면 한 단계 뒤로
        navigationController.popViewController(animated: true)
    }
}

// MARK: - 개별 사운드 Row 뷰

final class SoundRowView: UIView {
    
    // row 클릭 시 호출되는 클로저
    var onTap: (() -> Void)?
    
    // 사운드 이름 라벨
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 18, weight: .bold)
    }
    
    // 선택 표시 체크 아이콘
    private let checkImageView = UIImageView().then {
        $0.image = UIImage(systemName: "checkmark")
        $0.tintColor = UIColor(red: 1.0, green: 149/255, blue: 0, alpha: 1.0)
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    // 하단 구분선
    private let dividerView = UIView().then {
        $0.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
    }
    
    // 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // UI 구성
    private func configureUI() {
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(checkImageView)
        addSubview(dividerView)
        
        // 제목 위치
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
        
        // 체크 아이콘 위치
        checkImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        
        // 구분선 위치
        dividerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        // 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rowTapped))
        addGestureRecognizer(tapGesture)
    }
    
    // 데이터 설정
    func configure(title: String, showsDivider: Bool) {
        titleLabel.text = title
        dividerView.isHidden = !showsDivider
    }
    
    // 선택 상태 표시
    func setSelected(_ selected: Bool) {
        checkImageView.isHidden = !selected
    }
    
    // row 클릭 처리
    @objc
    private func rowTapped() {
        onTap?()
    }
}
