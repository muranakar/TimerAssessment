//
//  FIM.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import Foundation
import RealmSwift

// MARK: - Assessor 評価者
final class Assessor: Object {
    @objc dynamic var uuidString = UUID().uuidString
    @objc dynamic var name = ""
    var targetPersons = List<TargetPerson>()
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

// MARK: - TagetPerson　対象者
final class TargetPerson: Object {
    @objc dynamic var uuidString = UUID().uuidString
    @objc dynamic var name = ""
    var FIM = List<FIM>()
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
    let assessors = LinkingObjects(fromType: Assessor.self, property: "targetPersons")

    override class func primaryKey() -> String? {
        "uuidString"
    }

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

// MARK: - FIM　評価指標
final class FIM: Object {
    @objc dynamic var uuidString = UUID().uuidString
    // RealmOptionalを用いて、nullを許容したほうが良いか？理解できていない。
    // RealmOptionalの場合、let （定数）で定義する必要があるため、数値の編集ができないか？
    @objc dynamic var eating = 0
    @objc dynamic var grooming = 0
    @objc dynamic var bathing = 0
    @objc dynamic var dressingUpperBody = 0
    @objc dynamic var dressingLowerBody  = 0
    @objc dynamic var toileting = 0
    @objc dynamic var bladderManagement = 0
    @objc dynamic var bowelManagement = 0
    @objc dynamic var transfersBedChairWheelchair = 0
    @objc dynamic var transfersToilet = 0
    @objc dynamic var transfersBathShower = 0
    @objc dynamic var walkWheelchair = 0
    @objc dynamic var stairs = 0
    @objc dynamic var comprehension = 0
    @objc dynamic var expression = 0
    @objc dynamic var socialInteraction = 0
    @objc dynamic var problemSolving = 0
    @objc dynamic var memory = 0
    @objc dynamic var createdAt: Date?
    @objc dynamic var updatedAt: Date?

    let targetPersons = LinkingObjects(fromType: TargetPerson.self, property: "FIM")
    ///　運動項目合計値
    var sumTheMotorSubscaleIncludes: Int {
        eating + grooming + bathing + dressingUpperBody +
        dressingLowerBody + toileting + bladderManagement +
        bowelManagement + transfersBedChairWheelchair +
        transfersToilet + transfersBathShower +
        walkWheelchair + stairs
    }
    ///　認知項目合計値
    var sumTheCognitionSubscaleIncludes: Int {
        comprehension + expression + socialInteraction + problemSolving + memory
    }
    ///　全合計値
    var sumAll: Int {
        eating + grooming + bathing + dressingUpperBody + dressingLowerBody
        + toileting + bladderManagement + bowelManagement
        + transfersBedChairWheelchair + transfersToilet
        + transfersBathShower + walkWheelchair
        + stairs + comprehension + expression
        + socialInteraction + problemSolving + memory
    }

    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }

    override class func primaryKey() -> String? {
        "uuidString"
    }

    convenience init(
        eating: Int,
        grooming: Int,
        bathing: Int,
        dressingUpperBody: Int,
        dressingLowerBody: Int,
        toileting: Int,
        bladderManagement: Int,
        bowelManagement: Int,
        transfersBedChairWheelchair: Int,
        transfersToilet: Int,
        transfersBathShower: Int,
        walkWheelchair: Int,
        stairs: Int,
        comprehension: Int,
        expression: Int,
        socialInteraction: Int,
        problemSolving: Int,
        memory: Int,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.init()
        self.eating = eating
        self.grooming = grooming
        self.bathing = bathing
        self.dressingUpperBody = dressingUpperBody
        self.dressingLowerBody = dressingLowerBody
        self.toileting = toileting
        self.bladderManagement = bladderManagement
        self.bowelManagement = bowelManagement
        self.transfersBedChairWheelchair = transfersBedChairWheelchair
        self.transfersToilet = transfersToilet
        self.transfersBathShower = transfersBathShower
        self.walkWheelchair = walkWheelchair
        self.stairs = stairs
        self.comprehension = comprehension
        self.expression = expression
        self.socialInteraction = socialInteraction
        self.problemSolving = problemSolving
        self.memory = memory
        if let createdAt = createdAt {
             self.createdAt = createdAt
        }
        if let updatedAt = updatedAt {
            self.updatedAt = updatedAt
        }
    }
}
