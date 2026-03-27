# ⏰ 알람 앱(AlarmApp)

알람, 타이머, 스톱워치 기능을 구현한 iOS 애플리케이션입니다.  
iPhone 기본 시계 앱의 알람, 타이머, 스톱워치 기능을 참고하여 구현했으며,  
프로젝트를 진행하며 **MVVM 아키텍처**, **RxSwift 바인딩**, **AVAudioEngine 기반 사운드 재생**,  
**UserDefaults를 활용한 데이터 저장** 등을 학습하고 적용했습니다.

---

## 📌 프로젝트 개요

- **프로젝트명**: 정인이네 알람
- **개발 기간**: 2026.03.20(금) ~ 2026.03.30(월)
- **개발 인원**: 1인 개인 프로젝트
- **개발 목적**: MVVM 구조를 적용하여 기능별 역할 분리와 상태 관리를 연습하기 위해 진행한 프로젝트입니다.

---

## 🎯 프로젝트 목표

이 프로젝트를 시작할 때 세운 목표는 다음과 같습니다.

1. **알람 / 타이머 / 스톱워치 핵심 기능 구현**
2. **MVVM 아키텍처 적용**
3. **사용자 입력과 상태 변화가 화면에 반영되는 흐름 이해**
4. **사운드 재생, 시간 계산, 로컬 저장 등 실제 앱에서 필요한 기능 구현**
5. **iOS 앱 개발의 전체 흐름 경험**

---

## 🛠 기술 스택

### Language
- Swift

### UI
- UIKit
- SnapKit
- Then

### Architecture
- MVVM

### Reactive Programming
- RxSwift
- RxCocoa

### Storage
- UserDefaults

### Notification / Audio
- UserNotifications
- AVAudioEngine

---

## 📂 프로젝트 구조

```bash
AlarmApp
├── App
├── Common
├── Model
│ ├── Alarm
│ └── Timer
├── View
│ ├── Alarm
│ │ ├── Cells
│ │ ├── Components
│ │ └── Controllers
│ ├── Stopwatch
│ └── Timer
│ │ ├── Cells
│ │ ├── Controllers
│ ├── MainTabBarViewController.swift
├── ViewModel
└── SceneDelegate.swift
```

---

## 📸 실행 화면

<!-- 여기에 스크린샷 이미지 추가 -->
<p align="center">
<img src="https://github.com/" width="250"/>
</p>

---

## 📱 주요 기능

### 1. 알람
- 알람 추가 / 수정 / 삭제
- 알람 ON / OFF 토글
- 반복 요일 설정
- 알람 레이블 설정
- 알람 사운드 선택
- 스누즈(Snooze) 기능
- 알람 시간에 맞춰 로컬 알림 예약

### 2. 타이머
- 원하는 시간 설정 후 카운트다운 시작
- 남은 시간 실시간 표시
- 종료 예정 시각 표시
- 타이머 종료 시 사운드 재생
- 최근 사용한 타이머 목록 저장 및 재실행

### 3. 스톱워치
- 시작 / 중단 / 재설정
- 경과 시간 실시간 측정
- 랩(Lap) 기록 기능
- 최신 랩을 리스트 상단에 표시
- 앱 종료 후에도 상태 복원 가능하도록 저장 처리

---

## 🧩 아키텍처

이 프로젝트는 **MVVM(Model - View - ViewModel)** 구조를 기반으로 구현했습니다.

### Model
앱에서 사용하는 데이터를 정의하고 관리하는 역할을 담당합니다.

- 알람 시간, 반복 요일, 사운드 이름, 스누즈 여부 등 알람 데이터 관리
- 타이머 시간, 최근 항목 데이터 관리
- 스톱워치 랩 기록 및 저장 데이터 구조 관리

### View
사용자에게 보여지는 화면과 UI 이벤트를 처리합니다.

- 알람 목록 / 알람 추가 / 알람 편집 화면
- 타이머 설정 / 실행 화면
- 스톱워치 화면
- 버튼 탭, 셀 선택, 토글 변경 등 사용자 입력 처리

### ViewModel
View와 Model 사이에서 데이터 흐름과 비즈니스 로직을 담당합니다.

- 알람 추가 / 수정 / 삭제 / 토글 로직 처리
- Notification 예약 및 취소
- 타이머 카운트다운 및 종료 처리
- 스톱워치 상태 변경 및 랩 기록 관리
- View에 필요한 형식으로 데이터를 가공하여 전달

---

