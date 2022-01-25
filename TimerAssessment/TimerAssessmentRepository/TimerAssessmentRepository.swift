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
    func loadAssessor() -> [RealmAssessor] {
        let assessors = realm.objects(RealmAssessor.self)
        let assessorsArray = Array(assessors)
        return assessorsArray
    }
    // 評価者UUIDによる評価者（一人）の呼び出し
    func loadAssessor(assessorUUID: UUID) -> RealmAssessor? {
        let assessor = realm.object(ofType: RealmAssessor.self, forPrimaryKey: assessorUUID.uuidString)
        return assessor
    }
    // 対象者UUIDによる評価者（一人）の呼び出し
    func loadAssessor(targetPersonUUID: UUID) -> RealmAssessor? {
        guard let fetchedTargetPerson = realm.object(
            ofType: RealmTargetPerson.self,
            forPrimaryKey: targetPersonUUID.uuidString
        ) else { return nil }
        return fetchedTargetPerson.assessors.first
    }
    //　評価者の追加
    func apppendAssessor(assesor: RealmAssessor) {
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.add(assesor)
        }
    }
    // 評価者の更新
    func updateAssessor(uuid: UUID, name: String) {
        // swiftlint:disable:next force_cast
        try! realm.write {
            let assessor = realm.object(ofType: RealmAssessor.self, forPrimaryKey: uuid.uuidString)
            assessor?.name = name
        }
    }
    // 評価者の削除
    func removeAssessor(uuid: UUID) {
        guard let assessor = realm.object(ofType: RealmAssessor.self, forPrimaryKey: uuid.uuidString) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(assessor)
        }
    }

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

    // MARK: - ここまで実装
    //  一人のAssessmentItemのTimerAssessmentデータの追加
    func appendFIM(targetPersonUUID: UUID, fim: FIM) {
        guard let list = realm.object(
            ofType: TargetPerson.self,
            forPrimaryKey: targetPersonUUID.uuidString
        )?.FIM else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            fim.createdAt = Date()
            list.append(fim)
        }
    }
    // TimerAssessmentデータの更新
    func updateFIM(fimItemNumArray: [Int], fimUUID: UUID) {
        // swiftlint:disable:next force_cast
        try! realm.write {
            let loadedFIM = realm.object(ofType: FIM.self, forPrimaryKey: fimUUID.uuidString)
            loadedFIM?.eating = fimItemNumArray[0]
            loadedFIM?.grooming = fimItemNumArray[1]
            loadedFIM?.bathing = fimItemNumArray[2]
            loadedFIM?.dressingUpperBody = fimItemNumArray[3]
            loadedFIM?.dressingLowerBody = fimItemNumArray[4]
            loadedFIM?.toileting = fimItemNumArray[5]
            loadedFIM?.bladderManagement = fimItemNumArray[6]
            loadedFIM?.bowelManagement = fimItemNumArray[7]
            loadedFIM?.transfersBedChairWheelchair = fimItemNumArray[8]
            loadedFIM?.transfersToilet = fimItemNumArray[9]
            loadedFIM?.transfersBathShower = fimItemNumArray[10]
            loadedFIM?.walkWheelchair = fimItemNumArray[11]
            loadedFIM?.stairs = fimItemNumArray[12]
            loadedFIM?.comprehension = fimItemNumArray[13]
            loadedFIM?.expression = fimItemNumArray[14]
            loadedFIM?.socialInteraction = fimItemNumArray[15]
            loadedFIM?.problemSolving = fimItemNumArray[16]
            loadedFIM?.memory = fimItemNumArray[17]
            loadedFIM?.updatedAt = Date()
            //            loadedFIM.eating = fimItemNumArray.eating
            //            loadedFIM.grooming = fimItemNumArray.grooming
            //            loadedFIM.bathing = fimItemNumArray.bathing
            //            loadedFIM.dressingUpperBody = fimItemNumArray.dressingUpperBody
            //            loadedFIM.dressingLowerBody = fimItemNumArray.dressingLowerBody
            //            loadedFIM.toileting = fimItemNumArray.toileting
            //            loadedFIM.bladderManagement = fimItemNumArray.bladderManagement
            //            loadedFIM.bowelManagement = fimItemNumArray.bowelManagement
            //            loadedFIM.transfersBedChairWheelchair = fimItemNumArray.transfersBedChairWheelchair
            //            loadedFIM.transfersToilet = fimItemNumArray.transfersToilet
            //            loadedFIM.transfersBathShower = fimItemNumArray.transfersBathShower
            //            loadedFIM.walkWheelchair = fimItemNumArray.walkWheelchair
            //            loadedFIM.stairs = fimItemNumArray.stairs
            //            loadedFIM.comprehension = fimItemNumArray.comprehension
            //            loadedFIM.expression = fimItemNumArray.expression
            //            loadedFIM.socialInteraction = fimItemNumArray.socialInteraction
            //            loadedFIM.problemSolving = fimItemNumArray.problemSolving
            //            loadedFIM.memory = fimItemNumArray.memory

            //            realm.add(fimItemNumArray, update: .modified)
            //            fimItemNumArray.updatedAt = Date()
        }
    }
    // TimerAssessmentデータの削除
    func removeFIM(fimUUID: UUID) {
        guard let fetchedFIM = realm.object(ofType: FIM.self, forPrimaryKey: fimUUID.uuidString) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(fetchedFIM)
        }
    }
}
