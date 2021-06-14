//
//  CalendarPickerViewModel.swift
//  
//
//  Created by Leko Murphy on 6/13/21.
//

import UIKit
import Combine
import LMTime

public protocol DayPickerViewModel {
    var dayHeaderSymbols: [String] { get }
    func indexPath(of day: Day) -> IndexPath?
    
    func numberOfItems(in section: Int) -> Int
    func numberOfSections() -> Int
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    func shouldSelectItem(at indexPath: IndexPath) -> Bool
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
}

public protocol DayPicker {
    var startDay: CurrentValueSubject<Day?, Never> { get }
    var endDay: CurrentValueSubject<Day?, Never> { get }
    
    func selectFirstValidDay()
    func setSelected(_ day: Day?)
    func setSelected(startDay: Day, endDay: Day)
}

public class CalendarDayPickerViewModel: DayPicker, DayPickerViewModel {

    public var isSingleDatePicker: Bool = false {
        didSet {
            selectedCells = []
        }
    }
    
    public init() {
        
    }
    
    // MARK: - DayPicker

    public var startDay = CurrentValueSubject<Day?, Never>(nil)
    
    public var endDay = CurrentValueSubject<Day?, Never>(nil)
    
    public func selectFirstValidDay() {
        setSelected(validDayRange.lowerBound)
    }
    
    /// Set selected day on calendar picker, or deselect it if `day == nil`.  If day is outside the set valid day range, it will be ignored
    public func setSelected(_ day: Day?) {
        guard let day = day else {
            startDayIndex = nil
            return
        }
        
        guard day >= validDayRange.lowerBound && day <= validDayRange.upperBound else {
            selectFirstValidDay()
            return
        }
        startDayIndex = indexPath(of: day)
        endDayIndex = nil
        updateSelectedCells()
    }

    public func setSelected(startDay: Day, endDay: Day) {
        guard validDayRange.contains(startDay), validDayRange.contains(endDay) else {
            return
        }
        
        self.setSelectedDayRange(range: startDay...endDay)
    }
    
    // MARK: - DayPickerViewModel
    
    public var dayHeaderSymbols: [String] {
        return self.calendar.shortWeekdaySymbols
    }
        
    public func indexPath(of day: Day) -> IndexPath? {
        guard validDayRange.contains(day) else { return nil }
        let firstValidMonth = validDayRange.lowerBound.month // 1 - 12
        
        let firstWeekdayOfMonthIndex = firstWeekdayDayOfMonthIndex(for: day.month, year: day.year) // 0 - 6
        let sectionDayIndex = day.day - 1
        
        let section = day.month - firstValidMonth
        let row = sectionDayIndex + firstWeekdayOfMonthIndex
        
        return IndexPath(row: row, section: section)
    }
    
    // MARK: - Internal
    
    private var selectedCells = [IndexPath]()
    
    private let monthDayCount = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31] // Jan - Dec (non-leap year)
    private let calendar = Calendar.autoupdatingCurrent
    private var startDayIndex : IndexPath? {
        didSet {
            guard let startDayIndex = startDayIndex else {
                startDay.send(nil)
                return
            }
            
            startDay.send(dayForIndexPath(startDayIndex))
        }
    }
    
    private var endDayIndex : IndexPath? {
        didSet {
            guard let endDayIndex = endDayIndex else {
                endDay.send(nil)
                return
            }
            
            endDay.send(dayForIndexPath(endDayIndex))
        }
    }
        
    private func setSelectedDayRange(range: ClosedRange<Day>) {
        guard !range.contains(where: { !validDayRange.contains($0) }) else {
            print("invalid day range")
            return
        }
        
        startDayIndex = indexPath(of: range.lowerBound)
        endDayIndex = indexPath(of: range.upperBound)
        updateSelectedCells()
    }
    
    private let defaultValidDayRange: ClosedRange<Day> = {
        let today = Day.today
        return today...today+365
    }()
        
    private let validDayRange: ClosedRange<Day> = Day.today...(Day.today + 365)
            
    private func isLeapMonth(year: Int, month: Int) -> Bool {
        return year % 4 == 0 && month == 2
    }
    
    private func dayForIndexPath(_ indexPath: IndexPath) -> Day? {
        let firstValidDay = validDayRange.lowerBound
                
        let sectionMonth = (firstValidDay.month - 1 + indexPath.section) % 12 + 1
        let sectionYear = firstValidDay.year + Int((firstValidDay.month - 1 + indexPath.section) / 12)
        
        let firstWeekdayOfMonthIndex = firstWeekdayDayOfMonthIndex(for: sectionMonth, year: sectionYear)
        
        if indexPath.row >= firstWeekdayOfMonthIndex {
            let day = indexPath.row - firstWeekdayOfMonthIndex + 1
            return Day(month: sectionMonth, day: day, year: sectionYear)
        }
        
        return nil
    }
    
    /**
     - Returns: Weekday (range:  0 -> 6) corresponding to the first day of the month.  eg. Feb 1, 2020 is a Saturday, the last day of the week, returns 6.
     */
    private func firstWeekdayDayOfMonthIndex(for month: Int, year: Int) -> Int {
        if let firstDayOfMonthDate = calendar.date(from: DateComponents(calendar: calendar, year: year, month: month, day: 1)) {
            return calendar.component(.weekday, from: firstDayOfMonthDate) - 1
        }
        assertionFailure("could not create firstDayOfMonthDate from given sectionMonth and sectionYear")
        return 0
    }
    
    private func updateSelectedCells() {
        guard let startDayIndex = startDayIndex else {
            selectedCells = []
            return
        }
                
        guard let endDayIndex = endDayIndex else {
            selectedCells = [startDayIndex]
            return
        }
        
        var paths : [IndexPath] = []
        
        for section in 0..<numberOfSections() {
            for row in 0..<numberOfItems(in: section) {
                let path = IndexPath(item: row, section: section)
                if path >= startDayIndex && path <= endDayIndex {
                    paths.append(path)
                }
            }
        }
        
        selectedCells = paths
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfItems(in section: Int) -> Int {
        let firstMonthIndex = validDayRange.lowerBound.month - 1
        let firstYear = validDayRange.lowerBound.year
        
        let sectionMonthIndex = (firstMonthIndex + section) % 12
        let sectionYear = firstYear + (firstMonthIndex + section) / 12
        
        var firstDayOfMonthIndex : Int = 0
        
        let firstDayOfMonthDateComponents = DateComponents(calendar: calendar, year: sectionYear, month: sectionMonthIndex + 1, day: 1)
        let firstDayOfMonthDate = calendar.date(from: firstDayOfMonthDateComponents)
        
        if firstDayOfMonthDate != nil {
            firstDayOfMonthIndex = calendar.component(.weekday, from: firstDayOfMonthDate!) - 1
        }
        
        if isLeapMonth(year: sectionYear, month: sectionMonthIndex + 1) {
            return 29 + firstDayOfMonthIndex
        }
        
        return monthDayCount[sectionMonthIndex] + firstDayOfMonthIndex
    }

    public func numberOfSections() -> Int {
        let startMonth = validDayRange.lowerBound.month
        let startYear = validDayRange.lowerBound.year
        let endMonth = validDayRange.upperBound.month
        let endYear = validDayRange.upperBound.year
        
        return (12 * (endYear - startYear)) + endMonth - startMonth + 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var view : CalendarMonthSectionHeaderView? = nil
        if kind == UICollectionView.elementKindSectionHeader {
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeader", for: indexPath) as? CalendarMonthSectionHeaderView
            
            let section = indexPath.section
            let firstMonthIndex = validDayRange.lowerBound.month - 1
            let firstYear = validDayRange.lowerBound.year
            let sectionYear = firstYear + (firstMonthIndex + section) / 12
            
            let sectionMonthIndex = (firstMonthIndex + section) % 12
            
            view?.titleLabel.text = calendar.monthSymbols[sectionMonthIndex] + " " + String(sectionYear)
        }
        
        return view ?? UICollectionReusableView()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! CalendarCollectionViewCell
        
        let firstValidDay = validDayRange.lowerBound
        let lastValidDay = validDayRange.upperBound
        
        let cellDay = dayForIndexPath(indexPath)
        
        if let cellDay = cellDay {
            cell.dayLabel.text = String(cellDay.day)
            
            if cellDay < firstValidDay || cellDay > lastValidDay {
                cell.dayLabel.textColor = .quaternaryLabel
            } else {
                cell.dayLabel.textColor = .label
            }
        } else {
            cell.dayLabel.text = ""
        }
        
        if selectedCells.contains(indexPath) && cellDay != nil {
            let highlightColor: UIColor = .systemBlue.withAlphaComponent(0.8)
            //UIColor(red: 0xEB / 0xFF, green: 0xF0 / 0xFF, blue: 0xFF / 0xFF, alpha: 0.8)
            
            if indexPath == startDayIndex {
                cell.backgroundColor = .systemBackground
                cell.circleView.backgroundColor = .label
                cell.dayLabel.textColor = .systemBackground
                if selectedCells.count == 1 {
                    cell.rightHighlight.backgroundColor = .clear
                } else {
                    cell.rightHighlight.backgroundColor = highlightColor
                }
                cell.leftHighlight.backgroundColor = .clear
            } else if indexPath == endDayIndex {
                cell.backgroundColor = .systemBackground
                cell.circleView.backgroundColor = .label
                cell.dayLabel.textColor = .systemBackground
                cell.rightHighlight.backgroundColor = .clear
                cell.leftHighlight.backgroundColor = highlightColor
            } else {
                cell.backgroundColor = highlightColor
                cell.circleView.backgroundColor = .clear
                cell.dayLabel.textColor = .label
                cell.rightHighlight.backgroundColor = .clear
                cell.leftHighlight.backgroundColor = .clear
            }
        } else {
            cell.backgroundColor = .systemBackground
            cell.circleView.backgroundColor = .clear
            cell.rightHighlight.backgroundColor = .clear
            cell.leftHighlight.backgroundColor = .clear
        }
        
        return cell
    }
        
    public func shouldSelectItem(at indexPath: IndexPath) -> Bool {
        guard let cellDay = dayForIndexPath(indexPath) else {
            return false
        }
        
        return cellDay >= validDayRange.lowerBound && cellDay <= validDayRange.upperBound
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if startDayIndex != nil && endDayIndex != nil && !isSingleDatePicker { // range is chosen, starting a new range
            endDayIndex = nil
            startDayIndex = indexPath
        } else if let startDayIndex = self.startDayIndex, !isSingleDatePicker { // chosen start, now choosing end
            if indexPath < startDayIndex {
                endDayIndex = nil
                self.startDayIndex = indexPath
            } else {
                endDayIndex = indexPath
            }
        } else { // nothing previously selected, choosing start day
            self.startDayIndex = indexPath
        }
        
        var cellsToUpdate = Set(selectedCells)
        updateSelectedCells()
        cellsToUpdate.formUnion(selectedCells)
        
        collectionView.reloadItems(at: Array(cellsToUpdate))
    }
}
