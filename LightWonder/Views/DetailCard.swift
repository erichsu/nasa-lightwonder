//
//  DetailCard.swift
//  LightWonder
//
//  Created by TingYao Hsu on 2017/4/30.
//  Copyright © 2017年 許庭耀. All rights reserved.
//

import UIKit

enum DetailCardStyle: String {
    case algae = "DetailCardAlgae"
    case sun = "DetailCardUV"
}

class DetailCard: UIView {

    
    init(_ style: DetailCardStyle, frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib(style.rawValue)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib(nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib(nil)
    }
    
    func loadViewFromNib(_ nibName: String?) {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName ?? "DetailCard", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func rightButtonPressed(_ sender: Any) {
        removeFromSuperview()
    }
}
