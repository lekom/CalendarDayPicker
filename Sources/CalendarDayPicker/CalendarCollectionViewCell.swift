//
//  CalendarCollectionViewCell.swift
//
//  Created by Leko Murphy on 10/29/19.
//  Copyright © 2019 Leko Murphy. All rights reserved.
//

import UIKit

class CalendarCollectionViewCell : UICollectionViewCell {
    let dayLabel = UILabel()
    let circleView = UIView()
    let leftHighlight = UIView()
    let rightHighlight = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        leftHighlight.translatesAutoresizingMaskIntoConstraints = false
        rightHighlight.translatesAutoresizingMaskIntoConstraints = false
                
        dayLabel.textAlignment = .center
        
        contentView.addSubview(leftHighlight)
        contentView.addSubview(rightHighlight)
        contentView.addSubview(circleView)
        contentView.addSubview(dayLabel)
        
        circleView.pinEdgesToSuperView()
        dayLabel.pinEdgesToSuperView()
            
        NSLayoutConstraint.activate([
            leftHighlight.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            leftHighlight.trailingAnchor.constraint(equalTo: contentView.centerXAnchor),
            leftHighlight.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftHighlight.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            
            rightHighlight.leadingAnchor.constraint(equalTo: contentView.centerXAnchor),
            rightHighlight.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rightHighlight.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightHighlight.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleView.layer.cornerRadius = contentView.bounds.size.height / 2
    }
}
