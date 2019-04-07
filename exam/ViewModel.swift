//
//  ViewModel.swift
//  exam
//
//  Created by cha on 05/04/2019.
//  Copyright © 2019 chacha. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

struct ViewModel {
//    var data: BehaviorRelay<[String: Any]> = BehaviorRelay(value: [:])
    var data: BehaviorRelay<Model> = BehaviorRelay(value: Model(documents: [], meta: [:]))
    var disposeBag = DisposeBag()
    
    func requestData(query: String, sort: String? = nil, size: Int = PAGE_SIZE, page: Int = 1) {
        Indicator.show()
        Router.searchImage(query: query, sort: sort, size: size, page: page)
            .request()
            .subscribe(onNext: { callback in
                guard let _documents = callback["documents"] as? [[String: Any]],
                    let _meta = callback["meta"] as? [String: Any],
                    _documents.count > 0
                    else {
                        self.showNoItemView(NO_ITEM_TEX)
                        return
                }
                
                self.data.accept(Model(documents: _documents, meta: _meta))
                Indicator.hide()
            }, onError: { (error) in
                self.showNoItemView(error.localizedDescription)
            })
          .disposed(by: disposeBag)
    }
    
    func appendData(query: String, sort: String? = nil) {
        Router.searchImage(
            query: query,
            sort: sort,
            size: PAGE_SIZE,
            page: data.value.documents.count / PAGE_SIZE + 1
            ).request()
            .subscribe(onNext: { callback in
                guard let _documents = callback["documents"] as? [[String: Any]],
                    let _meta = callback["meta"] as? [String: Any]
                    else {
                        return
                }
                
                let documents: [[String: Any]] = self.data.value.documents + _documents
                self.data.accept(Model(documents: documents, meta: _meta))
                
            }, onError: { (error) in
                
            })
        .disposed(by: disposeBag)
    }
    
    fileprivate func showNoItemView(_ msg: String) {
        self.data.accept(
            Model(
                documents: [],
                meta: [
                    "msg": msg
                ])
        )
        
        
        Indicator.hide()
    }
}

struct Model {
    var documents: [[String: Any]]
    var meta: [String: Any]
}
