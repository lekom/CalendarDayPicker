//
//  CalendarDatePickerViewController.swift
//
//  Created by Leko Murphy on 10/25/19.
//  Copyright © 2019 Leko Murphy. All rights reserved.
//

import UIKit
import LMTime

public class CalendarDatePickerView : UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        
    private let viewModel: DayPickerViewModel
    
    private(set) lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private(set) lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 5.0
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.clipsToBounds = true
        return stack
    }()
        
    private lazy var dayHeadersContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dayHeaders: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        for day in viewModel.dayHeaderSymbols {
            let dayHeader = UILabel()
            dayHeader.translatesAutoresizingMaskIntoConstraints = false
            dayHeader.text = String(day.first!) //first character of the day
            dayHeader.textAlignment = .center
            dayHeader.textColor = .black
            stack.addArrangedSubview(dayHeader)
        }
        return stack
    }()
    
    private var dateRangeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 18)
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public var title: String? {
        didSet {
            dateRangeLabel.text = title
        }
    }
    
    private var collectionViewLayout: UICollectionViewFlowLayout?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        self.collectionViewLayout = layout
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .white
        
        collectionView.dataSource = self
        collectionView.layoutMargins = .zero
        collectionView.clipsToBounds = true
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: "myCell")
        collectionView.register(CalendarMonthSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "sectionHeader")
        
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.sectionHeadersPinToVisibleBounds = true
        layout.headerReferenceSize = CGSize(width: UIView.noIntrinsicMetric, height: 30)
        return collectionView
    }()
    
    public func addShadowAndRoundCorners(withRadius radius: CGFloat) {
        contentView.layer.cornerRadius = radius
        contentView.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius).cgPath
        self.layer.masksToBounds = false
        self.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    public init(viewModel: DayPickerViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        
        self.addSubview(contentView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(dateRangeLabel)
        stackView.addArrangedSubview(dayHeadersContainerView)
        dayHeadersContainerView.addSubview(dayHeaders)
        stackView.addArrangedSubview(collectionView)

        stackView.pinEdgesToSuperView()
        dayHeaders.pinEdgesToSuperView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // prevent minute gaps due to mod(view.bounds.width, 7) != 0...
        let width = floor(self.bounds.width / 7) * 7
        self.contentView.frame = CGRect(x: round((self.bounds.width - width) / 2),
                                        y: 0,
                                        width: width,
                                        height: self.bounds.height)
        
        collectionViewLayout?.invalidateLayout()
    }
    
    public func scrollToToday() {
        scrollTo(day: Day.today)
    }
    
    public func scrollTo(day: Day) {
        guard let indexPath = viewModel.indexPath(of: day) else { return }
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = contentView.frame.size.width / 7
        return CGSize(width: size, height: size)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return viewModel.shouldSelectItem(at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return viewModel.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return viewModel.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
}
