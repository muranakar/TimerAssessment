//
//  FIMRepository.swift
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
    @objc dynamic var resultTimer: Double = 0
    @objc dynamic var createdAt: Date?
    @objc dynamic var updatedAt: Date?
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
    let assessmentItems = LinkingObjects(fromType: RealmAssessmentItem.self, property: "timerAssessments")

    override class func primaryKey() -> String? {
        "uuidString"
    }

    convenience init(resultTimer: Double,
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

final class TimerAssessmentRepository {
    // swiftlint:disable:next force_cast
    private let realm = try! Realm()

    // MARK: - AssessorRepository
    // 全評価者の呼び出し
    func loadAssessor() -> [Assessor] {
        let realmAssessors = realm.objects(RealmAssessor.self)
        let realmAssessorsArray = Array(realmAssessors)
        let assessors = realmAssessorsArray.map {Assessor(managedObject: $0) }
        return assessors
    }
    // 評価者UUIDによる評価者（一人）の呼び出し
    func loadAssessor(assessor: Assessor) -> Assessor? {
        let realmAssessor = realm.object(ofType: RealmAssessor.self, forPrimaryKey: assessor.uuidString)
        guard let realmAssessor = realmAssessor else {
            return nil
        }
        let assessor = Assessor(managedObject: realmAssessor)
        return assessor
    }
    // 対象者UUIDによる評価者（一人）の呼び出し
    func loadAssessor(targetPerson: TargetPerson) -> Assessor? {
        guard let fetchedRealmTargetPerson = realm.object(
            ofType: RealmTargetPerson.self,
            forPrimaryKey: targetPerson.uuidString
        ) else {
            return nil
        }
        let realmAssessor = fetchedRealmTargetPerson.assessors.first
        guard let realmAssessor = realmAssessor else {
            return nil
        }
        let assessor = Assessor(managedObject: realmAssessor)
        return assessor
    }

    //　評価者の追加
    func apppendAssessor(assesor: Assessor) {
        // swiftlint:disable:next force_cast
        try! realm.write {
            let realmAssessor = assesor.managedObject()
            realm.add(realmAssessor)
        }
    }

    // 評価者の更新
    func updateAssessor(assessor: Assessor) {
        // swiftlint:disable:next force_cast
        try! realm.write {
            let realmAssessor = realm.object(ofType: RealmAssessor.self, forPrimaryKey: assessor.uuidString)
            realmAssessor?.name = assessor.name
        }
    }

    // 評価者の削除
    func removeAssessor(assessor: Assessor) {
        guard let assessor = realm.object(
            ofType: RealmAssessor.self,
            forPrimaryKey: assessor.uuidString
        ) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(assessor)
        }
    }

    // MARK: - TargetPersonRepository
    // 一人の評価者が評価するor評価した、対象者の配列の呼び出し
    func loadTargetPerson(assessor: Assessor) -> [TargetPerson] {
        let realmAssessor = realm.object(ofType: RealmAssessor.self, forPrimaryKey: assessor.uuidString)
        guard let realmTargetPersons = realmAssessor?.targetPersons else { return [] }
        let targetPersonsArray = Array(realmTargetPersons)
        let targetPersons = targetPersonsArray.map {TargetPerson(managedObject: $0)}
        return targetPersons
    }
    // 一人の対象者のUUIDから、一人の対象者の呼び出し
    func loadTargetPerson(targetPerson: TargetPerson) -> TargetPerson? {
        guard let realmTargetPerson = realm.object(
            ofType: RealmTargetPerson.self,
            forPrimaryKey: targetPerson.uuidString
        ) else {
            return nil
        }
        let targetPerson = TargetPerson(managedObject: realmTargetPerson)
        return targetPerson
    }
    // 一つのAssessmentItemのUUIDから、そのAssessmentItemがどの対象者かの呼び出し
    func loadTargetPerson(assessmentItem: AssessmentItem) -> TargetPerson? {
        guard let fetchedAssessmentItem = realm.object(
            ofType: RealmAssessmentItem.self,
            forPrimaryKey: assessmentItem.uuidString
        ) else {
            return nil
        }
        guard let realmTargetPerson = fetchedAssessmentItem.targetPersons.first else {
            return nil
        }
        let targetPerson = TargetPerson(managedObject: realmTargetPerson)
        return targetPerson
    }
    //  一人の評価者の対象者の追加
    func appendTargetPerson(assessor: Assessor, targetPerson: TargetPerson) {
        guard let list = realm.object(
            ofType: RealmAssessor.self,
            forPrimaryKey: assessor.uuidString
        )?.targetPersons else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            list.append(targetPerson.managedObject())
        }
    }

    // 一人の対象者のデータ更新
    func updateTargetPerson(targetPerson: TargetPerson) {
        try! realm.write {
            let realmTargetPerson = realm.object(ofType: RealmTargetPerson.self, forPrimaryKey: targetPerson.uuidString)
            realmTargetPerson?.name = targetPerson.name
        }
    }
    // 一人の対象者のデータ削除
    func removeTargetPerson(targetPerson: TargetPerson) {
        guard let fetchedRealmTagetPerson = realm.object(
            ofType: RealmTargetPerson.self,
            forPrimaryKey: targetPerson.uuidString
        ) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(fetchedRealmTagetPerson)
        }
    }

    // MARK: - AssessmentItemRepository
    // 一人の評価者が評価するor評価した、対象者の配列の呼び出し
    func loadAssessmentItem(targetPerson: TargetPerson) -> [AssessmentItem] {
        let realmTargetPerson = realm.object(ofType: RealmTargetPerson.self, forPrimaryKey: targetPerson.uuidString)
        guard let realmAssessmentItems = realmTargetPerson?.assessmentItems else { return [] }
        let realmAssessmentItemsArray = Array(realmAssessmentItems)
        let assessmentItemsArray = realmAssessmentItemsArray.map { AssessmentItem(managedObject: $0) }

        return assessmentItemsArray
    }

    // 一つのTimerAssessmentのUUIDから、そのTimerAssessmentが、どのAssessmentItemかの呼び出し
    func loadAssessmentItem(timerAssessment: TimerAssessment) -> AssessmentItem? {
        guard let fetchedRealmTimerAssessment = realm.object(
            ofType: RealmTimerAssessment.self,
            forPrimaryKey: timerAssessment.uuidString
        ) else {
            return nil
        }
        guard let realmAssessmentItem = fetchedRealmTimerAssessment.assessmentItems.first else {
            return nil
        }
        let assessmentItem = AssessmentItem(managedObject: realmAssessmentItem)
        return assessmentItem
    }

    //  一人の対象者のAssessmentItemの追加
    func appendAssessmentItem(
        targetPerson: TargetPerson,
        assessmentItem: AssessmentItem
    ) {
        guard let list = realm.object(
            ofType: RealmTargetPerson.self,
            forPrimaryKey: targetPerson.uuidString
        )?.assessmentItems else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            list.append(assessmentItem.managedObject())
        }
    }

    // 一つのAssessmentItemのデータ更新
    func updateAssessmentItem(assessmentItem: AssessmentItem) {
        try! realm.write {
            let realmAssessmentItem = realm.object(
                ofType: RealmAssessmentItem.self,
                forPrimaryKey: assessmentItem.uuidString
            )
            realmAssessmentItem?.name = assessmentItem.name
        }
    }

    // 一つのAssessmentItemのデータ削除
    func removeAssessmentItem(assessmentItem: AssessmentItem) {
        guard let fetchedRealmAssessmentItem = realm.object(
            ofType: RealmAssessmentItem.self,
            forPrimaryKey: assessmentItem.uuidString
        ) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(fetchedRealmAssessmentItem)
        }
    }

    // MARK: - TimerAssessmentRepository

    //　一つのAssessmentItemのUUIDから、複数のTimerAssessmentのデータの呼び出し(並び替えあり)
    func loadTimerAssessment(
        assessmentItem: AssessmentItem,
        sortedAscending: Bool
    ) -> [TimerAssessment] {
        let timerAssessmentList = realm.object(
            ofType: RealmAssessmentItem.self,
            forPrimaryKey: assessmentItem.uuidString
        )?.timerAssessments.sorted(
            byKeyPath: "createdAt",
            ascending: sortedAscending
        )
        guard let realmTimerAssessments = timerAssessmentList else { return [] }
        let realmTimerAssessmentsArray = Array(realmTimerAssessments)
        let timerAssessments = realmTimerAssessmentsArray.map { TimerAssessment(managedObject: $0)}
        return timerAssessments
    }

    // 新しいソートメソッド: ソートキーと順序を指定
    func loadTimerAssessment(
        assessmentItem: AssessmentItem,
        sortBy keyPath: String,
        ascending: Bool
    ) -> [TimerAssessment] {
        let timerAssessmentList = realm.object(
            ofType: RealmAssessmentItem.self,
            forPrimaryKey: assessmentItem.uuidString
        )?.timerAssessments.sorted(
            byKeyPath: keyPath,
            ascending: ascending
        )
        guard let realmTimerAssessments = timerAssessmentList else { return [] }
        let realmTimerAssessmentsArray = Array(realmTimerAssessments)
        let timerAssessments = realmTimerAssessmentsArray.map { TimerAssessment(managedObject: $0)}
        return timerAssessments
    }
    //  一人のAssessmentItemのTimerAssessmentデータの追加
    func appendTimerAssessment(
        assessmentItem: AssessmentItem,
        timerAssessment: TimerAssessment
    ) {
        guard let list = realm.object(
            ofType: RealmAssessmentItem.self,
            forPrimaryKey: assessmentItem.uuidString
        )?.timerAssessments else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            list.append(timerAssessment.managedObject())
        }
    }

    // TimerAssessmentデータの更新
    func updateTimerAssessment(timerAssessment: TimerAssessment) {
        // swiftlint:disable:next force_cast
        try! realm.write {
            let loadedTimerAssessment = realm.object(
                ofType: RealmTimerAssessment.self,
                forPrimaryKey: timerAssessment.uuidString
            )
            loadedTimerAssessment?.resultTimer = timerAssessment.resultTimer
            loadedTimerAssessment?.updatedAt = timerAssessment.updatedAt
        }
    }

    // TimerAssessmentデータの削除
    func removeTimerAssessment(timerAssessment: TimerAssessment) {
        guard let fetchedRealmTimerAssessment = realm.object(
            ofType: RealmTimerAssessment.self,
            forPrimaryKey: timerAssessment.uuidString
        ) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(fetchedRealmTimerAssessment)
        }
    }
}

// MARK: - struct構造体、Realmオブジェクトへの変換、Realmオブジェクトからの変換のイニシャライザ・メソッド追加
private extension Assessor {
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
}

private extension TargetPerson {
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
}

private extension AssessmentItem {
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
}

private extension TimerAssessment {
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
    // swiftlint:disable:next file_length
}
