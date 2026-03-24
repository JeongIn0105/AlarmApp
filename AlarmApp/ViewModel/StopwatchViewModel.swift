//
//  StopwatchViewModel.swift
//  AlarmApp
//
//  Created by 이정인 on 3/20/26.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - 스톱워치 ViewModel 구현 (MVVM에서 로직 담당)
class StopwatchViewModel {
    
    // MARK: - 스톱워치 상태 정의
    enum StopwatchState: String {
        case initial // 초기 상태 (아직 시작 안함)
        case running // 실행 중
        case paused // 일시 정지 상태
    }
    
    // MARK: - 랩(Lap) 데이터 구조
    struct Lap: Codable {
        let number: Int // 랩 번호
        var time: TimeInterval // 해당 랩의 시간
    }
    
    // MARK: - 저장용 구조체 (UserDefaults에 저장)
    private struct StopwatchStorage: Codable {
        let elapsedTime: TimeInterval // 총 경과 시간
        let currentLapStartTime: TimeInterval // 현재 랩 시작 시점
        let lastLapUIUpdateTime: TimeInterval // UI 마지막 갱신 시점
        let state: String // 상태 (running, paused 등)
        let laps: [Lap] // 랩 리스트
        let savedAt: Date // 저장된 시점
    }
    
    // MARK: - UserDefaults Key
    private enum StorageKey {
        static let stopwatch = "stopwatch.storage"
    }
    
    // MARK: - 내부 상태 변수
    private var timer: Timer? // 0.01초마다 실행되는 타이머
    private var startDate: Date? // 시작 시각
    private var elapsedTime: TimeInterval = 0 // 누적 시간
    private var currentLapStartTime: TimeInterval = 0 // 현재 랩 시작 시간
    private var lastLapUIUpdateTime: TimeInterval = 0 // 마지막 UI 갱신 시간
    
    // MARK: - Rx 상태 관리 (View와 바인딩)
    let laps = BehaviorRelay<[Lap]>(value: []) // 랩 리스트
    let timeText = BehaviorRelay<String>(value: "00:00.00") // 화면 표시 시간
    let stateRelay = BehaviorRelay<StopwatchState>(value: .initial) // 상태
    
    // 현재 상태 getter
    var state: StopwatchState {
        stateRelay.value
    }
    
    // MARK: - 초기화 시 저장된 상태 복원
    init() {
        restoreState()
    }
    
    // ViewModel 해제 시 타이머 정리
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - 시작 버튼
    func start() {
        stateRelay.accept(.running) // 상태 변경
        
        // 기존 시간 이어서 시작
        startDate = Date().addingTimeInterval(-elapsedTime)
        
        // 기존 타이머 제거
        timer?.invalidate()
        
        // 0.01초마다 updateTimer 실행
        timer = Timer.scheduledTimer(
            timeInterval: 0.01,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
        
        // 스크롤 등에도 멈추지 않게 common 모드 추가
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
        
        // 첫 랩 생성 (처음 시작할 때)
        if laps.value.isEmpty {
            currentLapStartTime = 0
            lastLapUIUpdateTime = 0
            
            let firstLap = Lap(number: 1, time: 0)
            laps.accept([firstLap])
        }
        
        saveState() // 상태 저장
    }
    
    // MARK: - 정지 버튼
    func stop() {
        guard state == .running else { return }
        
        updateElapsedTime() // 시간 갱신
        updateCurrentLapIfNeeded(force: true) // 랩 강제 업데이트
        
        timer?.invalidate()
        timer = nil
        startDate = nil
        
        stateRelay.accept(.paused)
        saveState()
    }
    
    // MARK: - 리셋 버튼
    func reset() {
        timer?.invalidate()
        timer = nil
        
        elapsedTime = 0
        startDate = nil
        currentLapStartTime = 0
        lastLapUIUpdateTime = 0
        
        laps.accept([]) // 랩 초기화
        timeText.accept("00:00.00")
        stateRelay.accept(.initial)
        
        clearSavedState() // 저장 데이터 삭제
    }
    
    // MARK: - 랩 기록 버튼
    func recordLap() {
        guard state == .running else { return }
        guard !laps.value.isEmpty else { return }
        
        updateElapsedTime()
        
        var currentLaps = laps.value
        
        // 현재 랩 시간 계산
        let currentLapElapsed = elapsedTime - currentLapStartTime
        currentLaps[0].time = currentLapElapsed
        
        // 다음 랩 준비
        currentLapStartTime = elapsedTime
        lastLapUIUpdateTime = elapsedTime
        
        let newLapNumber = currentLaps[0].number + 1
        let newLap = Lap(number: newLapNumber, time: 0)
        
        // 최신 랩을 맨 위에 추가
        currentLaps.insert(newLap, at: 0)
        
        laps.accept(currentLaps)
        saveState()
    }
    
    // MARK: - 시간 포맷 변환 (00:00.00)
    func formattedTime(_ time: TimeInterval) -> String {
        let totalHundredths = Int(time * 100)
        let minutes = totalHundredths / 6000
        let seconds = (totalHundredths % 6000) / 100
        let hundredths = totalHundredths % 100
        
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }
    
    // MARK: - 강제 저장 (앱 종료 시 등)
    func persistNow() {
        if state == .running {
            updateElapsedTime()
            updateCurrentLapIfNeeded(force: true)
        }
        saveState()
    }
    
    // MARK: - 타이머 반복 호출 메서드
    @objc
    private func updateTimer() {
        updateElapsedTime()
        updateCurrentLapIfNeeded(force: false)
    }
    
    // 경과 시간 계산
    private func updateElapsedTime() {
        guard let startDate else { return }
        
        elapsedTime = Date().timeIntervalSince(startDate)
        timeText.accept(formattedTime(elapsedTime)) // UI 업데이트
    }
    
    // 랩 UI 업데이트 (0.1초마다)
    private func updateCurrentLapIfNeeded(force: Bool) {
        guard !laps.value.isEmpty else { return }
        
        if force || elapsedTime - lastLapUIUpdateTime >= 0.1 {
            var currentLaps = laps.value
            
            // 현재 랩 시간 갱신
            currentLaps[0].time = elapsedTime - currentLapStartTime
            
            laps.accept(currentLaps)
            lastLapUIUpdateTime = elapsedTime
        }
    }
    
    // MARK: - 상태 저장 (UserDefaults)
    private func saveState() {
        let storage = StopwatchStorage(
            elapsedTime: elapsedTime,
            currentLapStartTime: currentLapStartTime,
            lastLapUIUpdateTime: lastLapUIUpdateTime,
            state: stateRelay.value.rawValue,
            laps: laps.value,
            savedAt: Date()
        )
        
        do {
            let data = try JSONEncoder().encode(storage)
            UserDefaults.standard.set(data, forKey: StorageKey.stopwatch)
        } catch {
            print("스톱워치 저장 실패: \(error)")
        }
    }
    
    // MARK: - 상태 복원 (앱 재실행 시)
    private func restoreState() {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.stopwatch) else {
            return
        }
        
        do {
            let storage = try JSONDecoder().decode(StopwatchStorage.self, from: data)
            
            elapsedTime = storage.elapsedTime
            currentLapStartTime = storage.currentLapStartTime
            lastLapUIUpdateTime = storage.lastLapUIUpdateTime
            
            let restoredState = StopwatchState(rawValue: storage.state) ?? .initial
            
            switch restoredState {
            case .initial:
                laps.accept([])
                timeText.accept("00:00.00")
                stateRelay.accept(.initial)
                
            case .paused:
                laps.accept(storage.laps)
                timeText.accept(formattedTime(elapsedTime))
                stateRelay.accept(.paused)
                
            case .running:
                // 앱 종료 동안 흐른 시간 보정
                let additionalTime = Date().timeIntervalSince(storage.savedAt)
                elapsedTime += additionalTime
                
                var restoredLaps = storage.laps
                if !restoredLaps.isEmpty {
                    restoredLaps[0].time = elapsedTime - currentLapStartTime
                }
                
                laps.accept(restoredLaps)
                timeText.accept(formattedTime(elapsedTime))
                
                // 자동 실행 방지 → paused로 복원
                timer?.invalidate()
                timer = nil
                startDate = nil
                
                stateRelay.accept(.paused)
            }
            
        } catch {
            print("스톱워치 복원 실패: \(error)")
        }
    }
    
    // 저장 데이터 삭제
    private func clearSavedState() {
        UserDefaults.standard.removeObject(forKey: StorageKey.stopwatch)
    }
    
}
