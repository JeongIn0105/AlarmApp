//
//  TimerViewModel.swift
//  AlarmApp
//

import Foundation
import RxSwift
import RxCocoa

class TimerViewModel {
    
    var onTick: ((String) -> Void)?
    var onStateChanged: ((Bool) -> Void)?
    var onTimerFinished: (() -> Void)?
    var onRecentTimerFinished: (() -> Void)?
    var onEndTimeTextUpdated: ((String) -> Void)?
    var onSelectedDurationChanged: ((String) -> Void)?
    var onSelectedSoundChanged: ((String) -> Void)?
    var onLabelChanged: ((String) -> Void)?
    
    let recentItemsRelay = BehaviorRelay<[TimerRecentItem]>(value: [])
    
    private(set) var selectedDuration: TimeInterval = 0
    private(set) var remainingTime: TimeInterval = 0
    private(set) var isRunning: Bool = false
    
    private var mainTimer: Timer?
    private var recentListTimer: Timer?
    private var endDate: Date?
    
    private(set) var labelText: String = "타이머"
    
    private let recentItemsKey = "timer_recent_items"
    
    let availableSounds: [String] = [
        "레디얼(기본 설정)",
        "걸음",
        "골짜기",
        "반향",
        "머큐리"
    ]
    
    private(set) var selectedSound: String = "레디얼(기본 설정)"
    
    init() {
        loadRecentItems()
    }
    
    deinit {
        invalidateMainTimer()
        invalidateRecentListTimer()
    }
    
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
    
    func startTimer(shouldSaveRecent: Bool = true) {
        guard selectedDuration > 0 else { return }
        
        invalidateMainTimer()
        
        remainingTime = selectedDuration
        endDate = Date().addingTimeInterval(remainingTime)
        isRunning = true
        
        if shouldSaveRecent {
            saveRecent(duration: selectedDuration)
        }
        
        onStateChanged?(true)
        onTick?(formatTime(remainingTime))
        onSelectedDurationChanged?(titleText(selectedDuration))
        onEndTimeTextUpdated?(endTimeText(remainingTime))
        onSelectedSoundChanged?(displaySoundName)
        onLabelChanged?(labelText)
        
        mainTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tickMainTimer()
        }
    }
    
    func pauseTimer() {
        guard isRunning else { return }
        invalidateMainTimer()
        isRunning = false
        onStateChanged?(false)
    }
    
    func resumeTimer() {
        guard !isRunning, remainingTime > 0 else { return }
        
        endDate = Date().addingTimeInterval(remainingTime)
        isRunning = true
        onStateChanged?(true)
        
        mainTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tickMainTimer()
        }
    }
    
    func cancelTimer() {
        invalidateMainTimer()
        isRunning = false
        remainingTime = selectedDuration
        
        onStateChanged?(false)
        onTick?(formatTime(remainingTime))
        onEndTimeTextUpdated?(endTimeText(remainingTime))
    }
    
    func configureMainTimerFromRecent(at index: Int) {
        let items = recentItemsRelay.value
        guard items.indices.contains(index) else { return }
        
        selectedDuration = items[index].remainingDuration
        remainingTime = items[index].remainingDuration
        
        onTick?(formatTime(remainingTime))
        onSelectedDurationChanged?(items[index].title)
        onEndTimeTextUpdated?(endTimeText(remainingTime))
    }
    
    func toggleRecentItemRunning(at index: Int) {
        var items = recentItemsRelay.value
        guard items.indices.contains(index) else { return }
        
        if items[index].remainingDuration <= 0 {
            items[index].remainingDuration = items[index].originalDuration
        }
        
        items[index].isRunning.toggle()
        recentItemsRelay.accept(items)
        persistRecentItems()
        
        updateRecentListTimerState()
    }
    
    func deleteRecentItem(at index: Int) {
        var items = recentItemsRelay.value
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
        recentItemsRelay.accept(items)
        persistRecentItems()
        updateRecentListTimerState()
    }
    
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
    
    var currentSoundFileName: String {
        soundFileName(for: selectedSound)
    }
    
    var displaySoundName: String {
        if selectedSound == "레디얼(기본 설정)" {
            return "레디얼 >"
        } else {
            return "\(selectedSound) >"
        }
    }
    
    private func tickMainTimer() {
        guard let endDate else { return }
        
        let timeLeft = max(0, endDate.timeIntervalSinceNow)
        remainingTime = ceil(timeLeft)
        
        onTick?(formatTime(remainingTime))
        onEndTimeTextUpdated?(endTimeText(remainingTime))
        
        if remainingTime <= 0 {
            invalidateMainTimer()
            isRunning = false
            onStateChanged?(false)
            onTick?("00:00")
            onTimerFinished?()
        }
    }
    
    private func updateRecentListTimerState() {
        let hasRunningItem = recentItemsRelay.value.contains(where: { $0.isRunning })
        
        if hasRunningItem {
            startRecentListTimerIfNeeded()
        } else {
            invalidateRecentListTimer()
        }
    }
    
    private func startRecentListTimerIfNeeded() {
        guard recentListTimer == nil else { return }
        
        recentListTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tickRecentItems()
        }
    }
    
    private func tickRecentItems() {
        var items = recentItemsRelay.value
        var finishedItemExists = false
        
        for index in items.indices {
            guard items[index].isRunning else { continue }
            
            items[index].remainingDuration -= 1
            
            if items[index].remainingDuration <= 0 {
                items[index].remainingDuration = 0
                items[index].isRunning = false
                finishedItemExists = true
            }
        }
        
        recentItemsRelay.accept(items)
        persistRecentItems()
        
        if finishedItemExists {
            onRecentTimerFinished?()
        }
        
        if !items.contains(where: { $0.isRunning }) {
            invalidateRecentListTimer()
        }
    }
    
    private func invalidateMainTimer() {
        mainTimer?.invalidate()
        mainTimer = nil
    }
    
    private func invalidateRecentListTimer() {
        recentListTimer?.invalidate()
        recentListTimer = nil
    }
    
    private func saveRecent(duration: TimeInterval) {
        var items = recentItemsRelay.value
        
        let item = TimerRecentItem(
            originalDuration: duration,
            title: titleText(duration)
        )
        
        items.insert(item, at: 0)
        
        if items.count > 10 {
            items.removeLast()
        }
        
        recentItemsRelay.accept(items)
        persistRecentItems()
    }
    
    private func persistRecentItems() {
        do {
            let data = try JSONEncoder().encode(recentItemsRelay.value)
            UserDefaults.standard.set(data, forKey: recentItemsKey)
        } catch {
            print("최근 항목 저장 실패: \(error)")
        }
    }
    
    private func loadRecentItems() {
        guard let data = UserDefaults.standard.data(forKey: recentItemsKey) else { return }
        
        do {
            var items = try JSONDecoder().decode([TimerRecentItem].self, from: data)
            
            // 앱 재실행 후에는 실행 중 상태를 모두 정지 상태로 복원
            for index in items.indices {
                items[index].isRunning = false
                
                if items[index].remainingDuration <= 0 {
                    items[index].remainingDuration = items[index].originalDuration
                }
            }
            
            recentItemsRelay.accept(items)
        } catch {
            print("최근 항목 불러오기 실패: \(error)")
        }
    }
    
    func clearRecentItems() {
        recentItemsRelay.accept([])
        UserDefaults.standard.removeObject(forKey: recentItemsKey)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let total = max(0, Int(time))
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
