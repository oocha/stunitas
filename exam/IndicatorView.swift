//
//  IndicatorView.swift
//  exam
//
//  Created by Cha Cha on 07/04/2019.
//  Copyright © 2019 chacha. All rights reserved.
//

import UIKit

class Indicator {
    fileprivate var loaderView: IndicatorView!
    static let shared = Indicator()
    
    private init() {
        if let _loader = UINib(nibName: "IndicatorView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? IndicatorView {
            _loader.frame = UIApplication.shared.keyWindow?.bounds ?? .zero
            loaderView = _loader
        }
    }
    
    static func show() {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        keyWindow.addSubview(Indicator.shared.loaderView)
        Indicator.shared.loaderView.indicator.startAnimating()
    }
    
    static func hide() {
        Indicator.shared.loaderView.indicator.stopAnimating()
        Indicator.shared.loaderView.removeFromSuperview()
    }
    
}

class IndicatorView: UIView {
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
}
