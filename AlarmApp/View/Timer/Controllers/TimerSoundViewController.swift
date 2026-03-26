//
//  TimerSoundViewController.swift
//  AlarmApp
//
//  Created by 이정인 on 3/20/26.
//

import UIKit
import SnapKit
import Then
import AVFoundation

// MARK: - 타이머 종료 시 사운드 구현
final class TimerSoundViewController: UIViewController {
    
    private let viewModel: TimerViewModel
    private var audioPlayer: AVAudioPlayer?
    
    private let titleLabel = UILabel().then {
        $0.text = "타이머 종료 시"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 22, weight: .bold)
        $0.textAlignment = .center
    }
    
    private let doneButton = UIButton(type: .system).then {
        $0.setTitle("설정", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        $0.backgroundColor = .orange
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
    }
    
    private let tableContainerView = UIView().then {
        $0.backgroundColor = UIColor(white: 0.22, alpha: 1.0)
        $0.layer.cornerRadius = 18
        $0.clipsToBounds = true
    }
    
    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.separatorColor = UIColor(white: 0.45, alpha: 1.0)
        $0.rowHeight = 56
        $0.showsVerticalScrollIndicator = true
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
        configureNavigation()
        configureUI()
        configureTableView()
    }
    
    private func configureNavigation() {
        title = ""
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func configureUI() {
        view.backgroundColor = .black
        
        [
            titleLabel,
            doneButton,
            tableContainerView
        ].forEach { view.addSubview($0) }
        
        tableContainerView.addSubview(tableView)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.centerX.equalToSuperview()
        }
        
        doneButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(74)
            $0.height.equalTo(48)
        }
        
        tableContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-90)
        }
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SoundCell")
    }
    
    @objc
    private func doneTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func previewSound(named sound: String) {
        let fileName = viewModel.soundFileName(for: sound)
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") else {
            print("❌ 파일 없음: \(fileName).wav")
            return
        }
        
        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("❌ 재생 실패: \(error)")
        }
    }
}

extension TimerSoundViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.availableSounds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sound = viewModel.availableSounds[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SoundCell", for: indexPath)
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.textLabel?.text = sound
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        
        if sound == viewModel.selectedSound {
            cell.accessoryType = .checkmark
            cell.tintColor = .orange
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sound = viewModel.availableSounds[indexPath.row]
        viewModel.updateSelectedSound(sound)
        previewSound(named: sound)
        tableView.reloadData()
    }
}
