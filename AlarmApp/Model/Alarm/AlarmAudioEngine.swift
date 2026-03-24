//
//  AlarmAudioEngine.swift
//  AlarmApp
//
//  Created by 이정인 on 3/23/26.
//

import Foundation
import AVFoundation

// MARK: - 알람 사운드 프리셋
enum AlarmSoundPreset: String, CaseIterable {
    case radar
    case basic
    case bell
    case chime
    
    var displayName: String {
        switch self {
        case .radar: return "레이더"
        case .basic: return "기본"
        case .bell: return "벨"
        case .chime: return "차임"
        }
    }
    
    // MARK: - 실제 번들에 들어있는 사운드 파일명
    var fileName: String {
        switch self {
        case .radar: return "radar"
        case .basic: return "basic"
        case .bell: return "bell"
        case .chime: return "chime"
        }
    }
}

// MARK: - AVAudioPlayer 기반 알람 사운드 재생기
final class AlarmAudioEngine {
    
    private var audioPlayer: AVAudioPlayer?
    private var repeatTimer: Timer?
    
    private(set) var isPlaying = false
    
    // MARK: - 오디오 세션 설정
    func setupAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try session.setActive(true)
    }
    
    // MARK: - 한 번 재생
    func preview(preset: AlarmSoundPreset) {
        stopRepeating()
        playOnce(preset: preset)
    }
    
    // MARK: - 반복 재생
    func startRepeating(preset: AlarmSoundPreset, interval: TimeInterval = 2.0) {
        stopRepeating()
        isPlaying = true
        playOnce(preset: preset)
        
        repeatTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self, self.isPlaying else { return }
            self.playOnce(preset: preset)
        }
    }
    
    // MARK: - 반복 중지
    func stopRepeating() {
        repeatTimer?.invalidate()
        repeatTimer = nil
        isPlaying = false
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    // MARK: - 실제 파일 재생
    private func playOnce(preset: AlarmSoundPreset) {
        guard let url = Bundle.main.url(forResource: preset.fileName, withExtension: "wav") else {
            print("사운드 파일을 찾을 수 없음:", preset.fileName)
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("재생 성공:", preset.fileName)
        } catch {
            print("사운드 재생 오류:", error)
        }
    }
}
