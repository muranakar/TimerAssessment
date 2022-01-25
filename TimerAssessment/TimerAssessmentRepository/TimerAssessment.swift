//
//  TimerAssessment.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/01/26.
//

import Foundation
import RealmSwift

public protocol Persistable {
    associatedtype ManagedObject: RealmSwift.Object
    init(managedObject: ManagedObject)
    func managedObject() -> ManagedObject
}

// MARK: - Assessor 評価者
struct Assessor {
    var uuidString = UUID().uuidString
    var name: String
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
}

extension Assessor: Persistable {
    init(managedObject: RealmAssessor) {
        self.uuidString = managedObject.uuidString
        self.name = managedObject.name
    }

    func managedObject() -> RealmAssessor {
        let realmAssessor = RealmAssessor()
        realmAssessor.uuidString = self.uuidString
        realmAssessor.name = self.name
        return realmAssessor
    }
    typealias ManagedObject = RealmAssessor
}

// MARK: - TagetPerson　対象者
struct TargetPerson {
    var uuidString = UUID().uuidString
    var name: String
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
}

extension TargetPerson: Persistable {
    init(managedObject: RealmTargetPerson) {
        self.uuidString = managedObject.uuidString
        self.name = managedObject.name
    }

    func managedObject() -> RealmTargetPerson {
        let realmTargetPerson = RealmTargetPerson()
        realmTargetPerson.uuidString = self.uuidString
        realmTargetPerson.name = self.name
        return realmTargetPerson
    }
    typealias ManagedObject = RealmTargetPerson
}

// MARK: - AssessmentItem　評価項目
struct AssessmentItem {
    var uuidString = UUID().uuidString
    var name: String
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
}

extension AssessmentItem: Persistable {
    init(managedObject: RealmAssessmentItem) {
        self.uuidString = managedObject.uuidString
        self.name = managedObject.name
    }

    func managedObject() -> RealmAssessmentItem {
        let realmAssessmentItem = RealmAssessmentItem()
        realmAssessmentItem.uuidString = self.uuidString
        realmAssessmentItem.name = self.name
        return realmAssessmentItem
    }
    typealias ManagedObject = RealmAssessmentItem
}
// MARK: - TimerAssessment 時間評価
struct TimerAssessment {
    var uuidString = UUID().uuidString
    var resultTimer: Float
    var createdAt: Date?
    var updatedAt: Date?
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
}

extension TimerAssessment: Persistable {
    init(managedObject: RealmTimerAssessment) {
        self.uuidString = managedObject.uuidString
        self.resultTimer = managedObject.resultTimer
        self.createdAt = managedObject.createdAt
        self.updatedAt = managedObject.updatedAt
    }

    func managedObject() -> RealmTimerAssessment {
        let realmTimerAssessment = RealmTimerAssessment()
        realmTimerAssessment.uuidString = self.uuidString
        realmTimerAssessment.resultTimer = self.resultTimer
        realmTimerAssessment.createdAt = self.createdAt
        realmTimerAssessment.updatedAt = self.updatedAt
        return realmTimerAssessment
    }
    typealias ManagedObject = RealmTimerAssessment
}
