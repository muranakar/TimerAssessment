//
//  TimerAssessment.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/01/26.
//

import Foundation
import RealmSwift

// MARK: - Assessor 評価者
struct Assessor {
    var uuidString = UUID().uuidString
    var name: String
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
}

// MARK: - TagetPerson　対象者
struct TargetPerson {
    var uuidString = UUID().uuidString
    var name: String
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
}

// MARK: - AssessmentItem　評価項目
struct AssessmentItem {
    var uuidString = UUID().uuidString
    var name: String
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
}

// MARK: - TimerAssessment 時間評価
struct TimerAssessment {
    var uuidString = UUID().uuidString
    var resultTimer: Float
    var createdAt: Date? = Date()
    var updatedAt: Date?
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
}
