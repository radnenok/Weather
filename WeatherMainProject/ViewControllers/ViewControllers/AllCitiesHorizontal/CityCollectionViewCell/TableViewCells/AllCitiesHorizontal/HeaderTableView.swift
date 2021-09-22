//
//  HeaderTableView.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 20.08.21.
//

import UIKit

class HeaderTableView: UIView {

    @IBOutlet weak var headerHeight: NSLayoutConstraint!
   
    @IBOutlet private var contentView: UIView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("\(type(of: self))", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func setupWith(title: String, backgroundColor: UIColor) {
        titleLabel.text = title
        contentView.backgroundColor = backgroundColor
    }
    
    override class func description() -> String {
        return "HeaderTableView"
    }
    
 
}
