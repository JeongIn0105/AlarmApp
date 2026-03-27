//
//  TimerSoundPlayer.swift
//  AlarmApp
//
//  Created by 이정인 on 3/23/26.
//

import Foundation
import AVFoundation

// MARK: - 타이머 사운드 재생 관리 클래스 (싱글톤)
final class TimerSoundPlayer {
    
    // 싱글톤 인스턴스 (앱 전체에서 하나만 사용)
    static let shared = TimerSoundPlayer()
    
    // 오디오 재생을 담당하는 플레이어
    private var audioPlayer: AVAudioPlayer?
    
    // 일정 시간 후 사운드를 정지시키기 위한 작업 객체
    private var stopWorkItem: DispatchWorkItem?
    
    // 외부에서 인스턴스 생성 못하도록 private 처리
    private init() { }
    
    // MARK: - 사운드 재생
    
    func playSound(named fileName: String) {
        
        // 기존에 재생 중이던 사운드 정지
        stopSound()
        
        // 파일 경로 찾기
        guard let url = soundURL(for: fileName) else {
            print("사운드 파일을 찾을 수 없음: \(fileName)")
            return
        }
        
        do {
            // 오디오 세션 설정 (백그라운드에서도 재생 가능)
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers] // 다른 사운드와 같이 재생 가능
            )
            
            // 오디오 세션 활성화
            try AVAudioSession.sharedInstance().setActive(true)
            
            // 오디오 플레이어 생성
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            // 재생 준비
            audioPlayer?.prepareToPlay()
            
            // 무한 반복 재생 (-1은 무한 루프)
            audioPlayer?.numberOfLoops = -1
            
            // 재생 시작
            audioPlayer?.play()
            
            // 일정 시간 후 자동으로 정지시키기 위한 작업 생성
            let workItem = DispatchWorkItem { [weak self] in
                self?.stopSound()
            }
            
            // workItem 저장
            stopWorkItem = workItem
            
            // 5초 후 실행 (자동 정지)
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 5,
                execute: workItem
            )
            
        } catch {
            // 재생 실패 시 로그 출력
            print("사운드 재생 실패: \(error)")
        }
    }
    
    // MARK: - 사운드 정지
    
    func stopSound() {
        
        // 예약된 정지 작업 취소
        stopWorkItem?.cancel()
        stopWorkItem = nil
        
        // 오디오 정지
        audioPlayer?.stop()
        
        // 플레이어 메모리 해제
        audioPlayer = nil
    }
    
    // MARK: - 사운드 파일 경로 찾기
    
    private func soundURL(for fileName: String) -> URL? {
        
        // 지원할 확장자 목록
        let extensions = ["mp3", "wav", "m4a", "caf", "aiff"]
        
        // 확장자를 순회하면서 파일 존재 여부 확인
        for ext in extensions {
            
            if let url = Bundle.main.url(
                forResource: fileName,
                withExtension: ext
            ) {
                return url
            }
        }
        
        // 파일 못 찾으면 nil 반환
        return nil
    }
}
