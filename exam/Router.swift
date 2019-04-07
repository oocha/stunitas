//
//  Router.swift
//  exam
//
//  Created by cha on 05/04/2019.
//  Copyright © 2019 chacha. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa

enum Router {
    case searchImage(query: String, sort: String?, size: Int?, page: Int?)
    
    var path: String {
        switch self {
        case .searchImage(let query, let sort, let size, let page):
            return "\(HOST)/v2/search/image?query=\(addingPercentEncodingForRFC3986(query) ?? query)&sort=\(sort ?? "")&size=\(size ?? 80)&page=\(page ?? 1)"
        }
    }
    
    static let manager: Alamofire.SessionManager = {
        let configuration: URLSessionConfiguration = .default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        configuration.httpAdditionalHeaders = [
            "Authorization": "KakaoAK \(KAKAO_API_KEY)" 
        ]
        
        let manager = Alamofire.SessionManager(configuration: configuration)
        return manager
    }()
    
    
    func request(_ method: HTTPMethod = .get,
                 body: [String: Any]? = nil,
                 encoding: ParameterEncoding = URLEncoding.default,
                 headers: HTTPHeaders? = nil) -> Observable<[String: Any]> {
        
        return Observable<[String: Any]>.create { observer in
            let request = Router.manager
                .request(self.path,
                         method: method,
                         parameters: body,
                         encoding: encoding,
                         headers: headers
                )
                .responseData(completionHandler: { response in
                switch response.result {
                case .success(let value):
                    do {
                        if let result = try JSONSerialization.jsonObject(with: value, options: .mutableContainers) as? [String: Any] {
                            observer.onNext(result)
                            observer.onCompleted()
                        }
                    } catch let error {
                        observer.onError(error)
                    }
                
                case .failure(let error):
                    observer.onError(error)
                }
            })
            
            
            //Finally, we return a disposable to stop the request
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func addingPercentEncodingForRFC3986(_ value: String) -> String? {
        // Encoding for RFC 3986. Unreserved Characters: ALPHA / DIGIT / “-” / “.” / “_” / “~”
        // Section 3.4 also explains that since a query will often itself include a URL it is preferable to not percent encode the slash (“/”) and question mark (“?”).
        let unreserved = "-._~/?"
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: unreserved)
        return value.addingPercentEncoding(withAllowedCharacters: allowed)
    }
}
