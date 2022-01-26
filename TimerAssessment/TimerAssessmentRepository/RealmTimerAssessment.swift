//
//  FIM.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import Foundation
import RealmSwift

// MARK: - RealmAssessor 評価者
final class RealmAssessor: Object {
    @objc dynamic var uuidString = ""
    @objc dynamic var name = ""
    var targetPersons = List<RealmTargetPerson>()
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
    override class func primaryKey() -> String? {
        "uuidString"
    }

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

// MARK: - RealmTagetPerson　対象者
final class RealmTargetPerson: Object {
    @objc dynamic var uuidString = ""
    @objc dynamic var name = ""
    var assessmentItems = List<RealmAssessmentItem>()
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
    let assessors = LinkingObjects(fromType: RealmAssessor.self, property: "targetPersons")

    override class func primaryKey() -> String? {
        "uuidString"
    }

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

// MARK: - RealmAssessmentItem　評価項目
final class RealmAssessmentItem: Object {
    @objc dynamic var uuidString = ""
    @objc dynamic var name = ""
    var timerAssessments = List<RealmTimerAssessment>()
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
    let targetPersons = LinkingObjects(fromType: RealmTargetPerson.self, property: "assessmentItems")

    override class func primaryKey() -> String? {
        "uuidString"
    }

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

// MARK: - RealmTimerAssessment 時間評価
final class RealmTimerAssessment: Object {
    @objc dynamic var uuidString = ""
    @objc dynamic var resultTimer: Float = 0
    @objc dynamic var createdAt: Date?
    @objc dynamic var updatedAt: Date?
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
    let assessmentItems = LinkingObjects(fromType: RealmAssessmentItem.self, property: "timerAssessments")

    override class func primaryKey() -> String? {
        "uuidString"
    }

    convenience init(resultTimer: Float,
                     createdAt: Date? = nil,
                     updatedAt: Date? = nil) {
        self.init()
        self.resultTimer = resultTimer
        if let createdAt = createdAt {
            self.createdAt = createdAt
        }
        if let updatedAt = updatedAt {
            self.updatedAt = updatedAt
        }
    }
}


