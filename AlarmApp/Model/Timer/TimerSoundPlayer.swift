//
//  TimerSoundPlayer.swift
//  AlarmApp
//

import Foundation
import AVFoundation

final class TimerSoundPlayer {
    
    static let shared = TimerSoundPlayer()
    
    private var audioPlayer: AVAudioPlayer?
    private var stopWorkItem: DispatchWorkItem?
    
    private init() { }
    
    func playSound(named fileName: String) {
        stopSound()
        
        guard let url = soundURL(for: fileName) else {
            print("사운드 파일을 찾을 수 없음: \(fileName)")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1   // 🔥 반복 재생
            audioPlayer?.play()
            
            // 5초 뒤 자동 정지
            let workItem = DispatchWorkItem { [weak self] in
                self?.stopSound()
            }
            
            stopWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
            
        } catch {
            print("사운드 재생 실패: \(error)")
        }
    }
    
    func stopSound() {
        stopWorkItem?.cancel()
        stopWorkItem = nil
        
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    private func soundURL(for fileName: String) -> URL? {
        let extensions = ["mp3", "wav", "m4a", "caf", "aiff"]
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: fileName, withExtension: ext) {
                return url
            }
        }
        
        return nil
    }
}
