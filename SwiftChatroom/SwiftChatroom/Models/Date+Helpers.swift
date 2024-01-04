//
//  Date+Helpers.swift
//  SwiftChatroom
//
//  Created by Yifan Wu on 2023/12/29.
//

import Foundation

extension Date {
    
    func discriptiveString(dateStyle: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        
        let daysBetween = self.daysBetween(date: Date())
        
        if daysBetween == 0 {
            return "Today"
        }
        else if daysBetween == 1 {
            return "Yesterday"
        }
        else if daysBetween < 5 {
            let weekdayIndex = Calendar.current.component(.weekday, from: self) - 1
            return formatter.weekdaySymbols[weekdayIndex]
        }
        return formatter.string(from: self)
    }
    
    func daysBetween(date: Date) -> Int {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: date)
        
        guard let daysBetween = calendar.dateComponents([.day], from: date1, to: date2).day else {
            return 0
        }
        return daysBetween
    }
}
