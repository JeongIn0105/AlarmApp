//
//  TimerViewModel.swift
//  AlarmApp
//
//  Created by 이정인 on 3/20/26.
//

import Foundation
import RxSwift
import RxCocoa

final class TimerViewModel {
    
    // MARK: - Output (Closure)
    var onTick: ((String) -> Void)?
    var onStateChanged: ((Bool) -> Void)?
    var onTimerFinished: (() -> Void)?
    var onEndTimeTextUpdated: ((String) -> Void)?
    var onSelectedDurationChanged: ((String) -> Void)?
    var onSelectedSoundChanged: ((String) -> Void)?
    var onLabelChanged: ((String) -> Void)?
    
    // MARK: - Rx Output
    let recentItemsRelay = BehaviorRelay<[TimerRecentItem]>(value: [])
    
    // MARK: - State
    private(set) var selectedDuration: TimeInterval = 0
    private(set) var remainingTime: TimeInterval = 0
    private(set) var isRunning: Bool = false
    
    private var timer: Timer?
    private var endDate: Date?
    
    private(set) var labelText: String = "타이머"
    
    let availableSounds: [String] = [
        "레디얼(기본 설정)",
        "걸음",
        "골짜기",
        "반향",
        "머큐리"
    ]
    
    private(set) var selectedSound: String = "레디얼(기본 설정)"
    
    deinit {
        invalidateTimer()
    }
    
    // MARK: - Input
    func updateSelectedDuration(_ duration: TimeInterval) {
        selectedDuration = duration
        
        if !isRunning {
            remainingTime = duration
            onTick?(formatTime(remainingTime))
            onSelectedDurationChanged?(titleText(duration))
            onEndTimeTextUpdated?(endTimeText(duration))
        }
    }
    
    func updateSelectedSound(_ sound: String) {
        selectedSound = sound
        onSelectedSoundChanged?(displaySoundName)
    }
    
    func updateLabel(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        labelText = trimmed.isEmpty ? "타이머" : trimmed
        onLabelChanged?(labelText)
    }
    
    func startTimer() {
        guard selectedDuration > 0 else { return }
        
        invalidateTimer()
        
        remainingTime = selectedDuration
        endDate = Date().addingTimeInterval(remainingTime)
        isRunning = true
        
        saveRecent(duration: selectedDuration)
        
        onStateChanged?(true)
        onTick?(formatTime(remainingTime))
        onSelectedDurationChanged?(titleText(selectedDuration))
        onEndTimeTextUpdated?(endTimeText(remainingTime))
        onSelectedSoundChanged?(displaySoundName)
        onLabelChanged?(labelText)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pauseTimer() {
        guard isRunning else { return }
        invalidateTimer()
        isRunning = false
        onStateChanged?(false)
    }
    
    func resumeTimer() {
        guard !isRunning, remainingTime > 0 else { return }
        
        endDate = Date().addingTimeInterval(remainingTime)
        isRunning = true
        onStateChanged?(true)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func cancelTimer() {
        invalidateTimer()
        isRunning = false
        remainingTime = selectedDuration
        
        onStateChanged?(false)
        onTick?(formatTime(remainingTime))
        onEndTimeTextUpdated?(endTimeText(remainingTime))
    }
    
    func startRecentTimer(at index: Int) {
        let items = recentItemsRelay.value
        guard items.indices.contains(index) else { return }
        
        selectedDuration = items[index].duration
        startTimer()
    }
    
    func deleteRecentItem(at index: Int) {
        var items = recentItemsRelay.value
        guard items.indices.contains(index) else { return }
        
        items.remove(at: index)
        recentItemsRelay.accept(items)
    }
    
    // MARK: - Sound
    func soundFileName(for sound: String) -> String {
        switch sound {
        case "레디얼(기본 설정)":
            return "radial"
        case "걸음":
            return "walk"
        case "골짜기":
            return "valley"
        case "반향":
            return "echo"
        case "머큐리":
            return "mercury"
        default:
            return "radial"
        }
    }
    
    var displaySoundName: String {
        if selectedSound == "레디얼(기본 설정)" {
            return "레디얼 >"
        } else {
            return "\(selectedSound) >"
        }
    }
    
    // MARK: - Private
    private func tick() {
        guard let endDate else { return }
        
        let timeLeft = max(0, endDate.timeIntervalSinceNow)
        remainingTime = ceil(timeLeft)
        
        onTick?(formatTime(remainingTime))
        onEndTimeTextUpdated?(endTimeText(remainingTime))
        
        if remainingTime <= 0 {
            invalidateTimer()
            isRunning = false
            onStateChanged?(false)
            onTick?("00:00")
            onTimerFinished?()
        }
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func saveRecent(duration: TimeInterval) {
        var items = recentItemsRelay.value
        let item = TimerRecentItem(duration: duration, title: titleText(duration))
        
        items.insert(item, at: 0)
        
        if items.count > 10 {
            items.removeLast()
        }
        
        recentItemsRelay.accept(items)
    }
    
    // MARK: - Formatter
    func formatTime(_ time: TimeInterval) -> String {
        let total = Int(time)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func titleText(_ time: TimeInterval) -> String {
        let total = Int(time)
        let minutes = total / 60
        let seconds = total % 60
        
        if minutes > 0 {
            return "\(minutes)분"
        } else {
            return "\(seconds)초"
        }
    }
    
    func endTimeText(_ time: TimeInterval) -> String {
        let date = Date().addingTimeInterval(time)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return "🔔 \(formatter.string(from: date))"
    }
}
