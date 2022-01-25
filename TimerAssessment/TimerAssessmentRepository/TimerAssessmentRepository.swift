//
//  FIMRepository.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import Foundation
import RealmSwift

final class TimerAssessmentRepository {
    // swiftlint:disable:next force_cast
    private let realm = try! Realm()

    // MARK: - AssessorRepository
    // 全評価者の呼び出し
    func loadAssessor() -> [Assessor] {
        let realmAssessors = realm.objects(RealmAssessor.self)
        let realmAssessorsArray = Array(realmAssessors)
        let Assessors = realmAssessorsArray.map {Assessor(managedObject: $0) }
        return Assessors
    }
    // 評価者UUIDによる評価者（一人）の呼び出し
    func loadAssessor(assessorUUID: UUID) -> Assessor? {
        let realmAssessor = realm.object(ofType: RealmAssessor.self, forPrimaryKey: assessorUUID.uuidString)
        guard let realmAssessor = realmAssessor else {
            return nil
        }
        let assessor = Assessor(managedObject: realmAssessor)
        return assessor
    }
    // 対象者UUIDによる評価者（一人）の呼び出し
    func loadAssessor(targetPersonUUID: UUID) -> Assessor? {
        guard let fetchedRealmTargetPerson = realm.object(
            ofType: RealmTargetPerson.self,
            forPrimaryKey: targetPersonUUID.uuidString
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
        guard let assessor = realm.object(ofType: RealmAssessor.self, forPrimaryKey: assessor.uuidString) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(assessor)
        }
    }

    // MARK: - ここまで完了
    // MARK: - TargetPersonRepository
    // 一人の評価者が評価するor評価した、対象者の配列の呼び出し
    func loadTargetPerson(assessorUUID: UUID) -> [RealmTargetPerson] {
        let assessor = realm.object(ofType: RealmAssessor.self, forPrimaryKey: assessorUUID.uuidString)
        guard let targetPersons = assessor?.targetPersons else { return [] }
        let targetPersonsArray = Array(targetPersons)
        return targetPersonsArray
    }
    // 一人の対象者のUUIDから、一人の対象者の呼び出し
    func loadTargetPerson(targetPersonUUID: UUID) -> RealmTargetPerson? {
        let targetPerson = realm.object(ofType: RealmTargetPerson.self, forPrimaryKey: targetPersonUUID.uuidString)
        return targetPerson
    }

    // 一つのFIMのUUIDから、そのAssessmentItemがどの対象者かの呼び出し
    func loadTargetPerson(assessmentItemUUID: UUID) -> RealmTargetPerson? {
        guard let fetchedFIM = realm.object(ofType: RealmAssessmentItem.self, forPrimaryKey: assessmentItemUUID.uuidString) else { return nil }
        return fetchedFIM.targetPersons.first
    }
    //  一人の評価者の対象者の追加
    func appendTargetPerson(assessorUUID: UUID, targetPerson: RealmTargetPerson) {
        guard let list = realm.object(
            ofType: RealmAssessor.self,
            forPrimaryKey: assessorUUID.uuidString
        )?.targetPersons else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            list.append(targetPerson)
        }
    }
    // 一人の対象者のデータ更新
    func updateTargetPerson(uuid: UUID, name: String) {
        try! realm.write {
            let targetPerson = realm.object(ofType: RealmTargetPerson.self, forPrimaryKey: uuid.uuidString)
            targetPerson?.name = name
        }
    }
    // 一人の対象者のデータ削除
    func removeTargetPerson(targetPersonUUID: UUID) {
        guard let fetchedTagetPerson = realm.object(
            ofType: RealmTargetPerson.self,
            forPrimaryKey: targetPersonUUID.uuidString
        ) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(fetchedTagetPerson)
        }
    }
    // MARK: - AssessmentItemRepository
    // 一人の評価者が評価するor評価した、対象者の配列の呼び出し
    func loadAssessmentItem(targetPersonUUID: UUID) -> [RealmAssessmentItem] {
        let targetPerson = realm.object(ofType: RealmTargetPerson.self, forPrimaryKey: targetPersonUUID.uuidString)
        guard let assessmentItems = targetPerson?.assessmentItems else { return [] }
        let assessmentItemsArray = Array(assessmentItems)
        return assessmentItemsArray
    }

    // 一つのAssessmentItemのUUIDから、一つのAssessmentItemの呼び出し
    func loadAssessmentItem(assessmentItemUUID: UUID) -> RealmAssessmentItem? {
        let assessmentItem = realm.object(ofType: RealmAssessmentItem.self, forPrimaryKey: assessmentItemUUID.uuidString)
        return assessmentItem
    }

    // 一つのTimerAssessmentのUUIDから、そのTimerAssessmentが、どのAssessmentItemかの呼び出し
    func loadAssessmentItem(timerAssessmentUUID: UUID) -> RealmAssessmentItem? {
        guard let fetchedTimerAssessment = realm.object(
            ofType: RealmTimerAssessment.self,
            forPrimaryKey: timerAssessmentUUID.uuidString
        ) else { return nil }
        return fetchedTimerAssessment.assessmentItems.first
    }

    //  一人の対象者のAssessmentItemの追加
    func appendAssessmentItem(targetPersonUUID: UUID, assessmentItem: RealmAssessmentItem) {
        guard let list = realm.object(
            ofType: RealmTargetPerson.self,
            forPrimaryKey: targetPersonUUID.uuidString
        )?.assessmentItems else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            list.append(assessmentItem)
        }
    }

    // 一つのAssessmentItemのデータ更新
    func updateAssessmentItem(assessmentItemUUID: UUID, name: String) {
        try! realm.write {
            let assessmentItem = realm.object(ofType: RealmAssessmentItem.self, forPrimaryKey: assessmentItemUUID.uuidString)
            assessmentItem?.name = name
        }
    }

    // 一つのAssessmentItemのデータ削除
    func removeAssessmentItem(assessmentItemUUID: UUID) {
        guard let fetchedAssessmentItem = realm.object(
            ofType: RealmAssessmentItem.self,
            forPrimaryKey: assessmentItemUUID.uuidString
        ) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(fetchedAssessmentItem)
        }
    }

    // MARK: - TimerAssessmentRepository
    // 一つのTimerAssessmentのUUIDから、TimerAssessmentのデータの呼び出し
    func loadTimerAssessment(timerAssessmentUUID: UUID) -> RealmTimerAssessment? {
        let timerAssessment = realm.object(ofType: RealmTimerAssessment.self, forPrimaryKey: timerAssessmentUUID.uuidString)
        return timerAssessment
    }
    //　一つのAssessmentItemのUUIDから、複数のTimerAssessmentのデータの呼び出し(並び替えあり)
    func loadTimerAssessment(
        assessmentItemUUID: UUID,
        sortedAscending: Bool
    ) -> [RealmTimerAssessment] {
        let timerAssessmentList = realm.object(
            ofType: RealmAssessmentItem.self,
            forPrimaryKey: assessmentItemUUID.uuidString
        )?.timerAssessments.sorted(
            byKeyPath: "createdAt",
            ascending: sortedAscending
        )
        guard let timerAssessmentList = timerAssessmentList else { return [] }
        let timerAssessmentListArray = Array(timerAssessmentList)
        return timerAssessmentListArray
    }

    //  一人のAssessmentItemのTimerAssessmentデータの追加
    func appendTimerAssessment(assessmentItemUUID: UUID, timerAssessment: RealmTimerAssessment) {
        guard let list = realm.object(
            ofType: RealmAssessmentItem.self,
            forPrimaryKey: assessmentItemUUID.uuidString
        )?.timerAssessments else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            timerAssessment.createdAt = Date()
            list.append(timerAssessment)
        }
    }

    // TimerAssessmentデータの更新
    func updateTimerAssessment(resultTimer: Float, timerAssessmentUUID: UUID) {
        // swiftlint:disable:next force_cast
        try! realm.write {
            let loadedTimerAssessment = realm.object(
                ofType: RealmTimerAssessment.self,
                forPrimaryKey: timerAssessmentUUID.uuidString
            )
            loadedTimerAssessment?.resultTimer = resultTimer
            loadedTimerAssessment?.updatedAt = Date()
            }
    }

    // TimerAssessmentデータの削除
    func removeTimerAssessment(timerAssessmentUUID: UUID) {
        guard let fetchedTimerAssessment = realm.object(
            ofType: RealmTimerAssessment.self,
            forPrimaryKey: timerAssessmentUUID.uuidString
        ) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(fetchedTimerAssessment)
        }
    }
}
