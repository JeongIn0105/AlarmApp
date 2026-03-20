//
//  NetworkManager.swift
//  AlarmApp
//
//  Created by 이정인 on 3/20/26.
//

import Foundation
import RxSwift

// MARK: - NetWorkError 생성
enum NetworkError: Error {
    case invalidUrl // 잘못된 URL이 들어오면 이 에러 사용.
    case dataFetchFail // 데이터 패치가 일반적으로 실패하면 이 에러 사용.
    case decodingFail // 디코딩이 실패하면 이 에러 사용.
}

class NetworkManager {
    
    // MARK: - 싱글톤 패턴을 사용한 네트워크 매니저(앱 전연적으로 인스턴스 단 하나만 살아있다)
    static let shared = NetworkManager() // 외부에서 NetworkManager를 사용할 때는 오직 shared라는 진입점을 통해서 fetch 메서드 사용 가능.
    
    private init() {} // 외부에서는 생성하지 못하게 막아버린다.
    
    // MARK: - RxSwift 사용
    // 이제 서버로부터 네트워크 통신을 하는 코드 작성.
    
    // 이제 공통으로 사용할 만한 fetch라는 NetworkManager 메서드 선언 -> ViewModel로 가서 사용하여 로직 작성.
    func fetch<T: Decodable>(url: URL) -> Single<T> { // T 타입이 Decodable을 만족하면 된다.
        
        return Single.create { observer in
            let session = URLSession(configuration: .default)
            session.dataTask(with: URLRequest(url: url)) { data, response, error in
                
                // error 코드 작성
                if let error = error {
                    observer(.failure(error))
                    return
                }
                
                // data, response 코드 작성
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode) else { // 200..<300 : 성공 범주
                    observer(.failure(NetworkError.dataFetchFail)) // 데이터 패치 실패
                    return
                }
                
                // MARK: JSON 디코딩 진행
                // do-catch 문 작성
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data) // T 타입
                    observer(.success(decodedData))
                } catch {
                    observer(.failure(NetworkError.decodingFail)) // 디코딩 실패
                }
            }.resume()
            
            return Disposables.create() // Single 완성
        }
    }
    
}
