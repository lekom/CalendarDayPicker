//
//  CalendarMonthSectionHeaderView.swift
//
//  Created by Leko Murphy on 11/17/19.
//  Copyright © 2019 Leko Murphy. All rights reserved.
//

import UIKit

class CalendarMonthSectionHeaderView : UICollectionReusableView {
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        self.backgroundColor = .systemBackground
        self.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
