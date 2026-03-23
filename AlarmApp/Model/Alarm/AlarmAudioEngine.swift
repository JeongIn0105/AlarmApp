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
    case opening
    case chime
    case digital
    case classic

    var displayName: String {
        switch self {
        case .radar:   return "레이더"
        case .opening: return "오프닝"
        case .chime:   return "차임"
        case .digital: return "디지털"
        case .classic: return "클래식"
        }
    }

    var frequencies: [Double] {
        switch self {
        case .radar:
            return [880, 1100, 880]
        case .opening:
            return [523, 659, 784, 1046]
        case .chime:
            return [1046, 784, 659, 523]
        case .digital:
            return [1200, 1200]
        case .classic:
            return [440, 550, 660]
        }
    }

    var noteInterval: Double {
        switch self {
        case .radar:   return 0.18
        case .digital: return 0.20
        default:       return 0.22
        }
    }

    var noteDuration: Double {
        switch self {
        case .digital: return 0.15
        default:       return 0.20
        }
    }
}

// MARK: - AVAudioEngine 기반 알람 사운드 재생기
final class AlarmAudioEngine {
    
    private let engine = AVAudioEngine()
    private var playerNodes: [AVAudioPlayerNode] = []
    private var repeatTimer: Timer?
    
    private(set) var isPlaying = false
    var volume: Float = 0.8
    
    func setupAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try session.setActive(true)
    }
    
    func preview(preset: AlarmSoundPreset) {
        stopRepeating()
        playOnce(preset: preset)
    }
    
    func startRepeating(preset: AlarmSoundPreset, interval: TimeInterval = 2.0) {
        stopRepeating()
        isPlaying = true
        playOnce(preset: preset)
        
        repeatTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self, self.isPlaying else { return }
            self.playOnce(preset: preset)
        }
    }
    
    func stopRepeating() {
        repeatTimer?.invalidate()
        repeatTimer = nil
        isPlaying = false
        stopEngineOnly()
    }
    
    private func playOnce(preset: AlarmSoundPreset) {
        stopEngineOnly()
        
        playerNodes.forEach { engine.detach($0) }
        playerNodes.removeAll()
        
        for frequency in preset.frequencies {
            let player = AVAudioPlayerNode()
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: nil)
            playerNodes.append(player)
            
            guard let buffer = makeToneBuffer(
                frequency: frequency,
                duration: preset.noteDuration
            ) else { continue }
            
            player.scheduleBuffer(buffer, completionHandler: nil)
        }
        
        do {
            try engine.start()
            playerNodes.forEach { $0.play() }
            
            let totalDuration =
                (Double(preset.frequencies.count - 1) * preset.noteInterval)
                + preset.noteDuration
                + 0.1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) { [weak self] in
                self?.stopEngineOnly()
            }
        } catch {
            print("AudioEngine 시작 오류: \(error)")
        }
    }
    
    private func makeToneBuffer(
        frequency: Double,
        duration: Double,
        sampleRate: Double = 44_100
    ) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        
        buffer.frameLength = frameCount
        let channelData = buffer.floatChannelData![0]
        let fadeFrames = Int(sampleRate * 0.04)
        
        for frame in 0..<Int(frameCount) {
            let sample = sin(2.0 * .pi * frequency * Double(frame) / sampleRate)
            
            var envelope = 1.0
            if frame < fadeFrames {
                envelope = Double(frame) / Double(fadeFrames)
            } else if frame > Int(frameCount) - fadeFrames {
                envelope = Double(Int(frameCount) - frame) / Double(fadeFrames)
            }
            
            channelData[frame] = Float(sample * envelope * Double(volume))
        }
        
        return buffer
    }
    
    private func stopEngineOnly() {
        if engine.isRunning {
            engine.stop()
            engine.reset()
        }
    }
}
