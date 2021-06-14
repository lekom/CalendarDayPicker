//
//  CalendarDayPickerViewController.swift
//  
//
//  Created by Leko Murphy on 6/13/21.
//

import UIKit

public class CalendarDayPickerViewController: UIViewController {
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBackgroundTap)))
        return view
    }()
    
    private lazy var calendarView: CalendarDatePickerView = {
        let view = CalendarDatePickerView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let viewModel: DayPickerViewModel
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundView)
        view.addSubview(calendarView)
        
        backgroundView.pinEdgesToSuperView()
        
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            calendarView.heightAnchor.constraint(equalTo: calendarView.widthAnchor),
            calendarView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        calendarView.addShadowAndRoundCorners(withRadius: 24)
    }
    
    public init(viewModel: DayPickerViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onBackgroundTap() {
        self.dismiss(animated: true, completion: nil)
    }
}
