//
//  DetailCard.swift
//  LightWonder
//
//  Created by TingYao Hsu on 2017/4/30.
//  Copyright © 2017年 許庭耀. All rights reserved.
//

import UIKit

enum DetailCardStyle: String {
    case algae, sun, normal
}

class DetailCard: UIView {

    var style: DetailCardStyle = .normal
    var img = "algea_02"
    var nibName = "DetailCard"
    @IBOutlet weak var icon: UIImageView!
    
    init(_ style: DetailCardStyle, frame: CGRect) {
        super.init(frame: frame)
        self.style = style
        switch style {
        case .algae:
            nibName = "DetailCardAlgae"
            img = "algea_02"
            break
        case .sun:
            nibName = "DetailCardUV"
            img = "temp_02"
            break
        default:
            break
        }
        loadViewFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
        icon.image = UIImage(named: img)?.withRenderingMode(.alwaysTemplate)
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
