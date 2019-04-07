//
//  Constant.swift
//  exam
//
//  Created by cha on 05/04/2019.
//  Copyright © 2019 chacha. All rights reserved.
//

import Foundation

public let HOST: String = "https://dapi.kakao.com"
public let KAKAO_API_KEY: String = "cd8fb21ce62cda5ef90331e60a71d692"
public let NO_ITEM_TEX: String = "검색된 데이터가 없습니다."
public let PAGE_SIZE: Int = 20
public let JSON_DECODER: JSONDecoder = {
    let decoder = JSONDecoder()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    decoder.dateDecodingStrategy = .formatted(formatter)
    return decoder
}()


public func ^=<Element>(lhs: Array<Element>, rhs: Int) -> Element? {
    guard lhs.startIndex..<lhs.endIndex ~= rhs else { return nil }
    return lhs[rhs]
}
