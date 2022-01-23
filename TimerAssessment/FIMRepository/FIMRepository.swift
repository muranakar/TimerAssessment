//
//  FIMRepository.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import Foundation
import RealmSwift

final class FIMRepository {
    // swiftlint:disable:next force_cast
    private let realm = try! Realm()

    // MARK: - AssessorRepository
    // 全評価者の呼び出し
    func loadAssessor() -> [Assessor] {
        let assessors = realm.objects(Assessor.self)
        let assessorsArray = Array(assessors)
        return assessorsArray
    }
    // 評価者UUIDによる評価者（一人）の呼び出し
    func loadAssessor(assessorUUID: UUID) -> Assessor? {
        let assessor = realm.object(ofType: Assessor.self, forPrimaryKey: assessorUUID.uuidString)
        return assessor
    }
    // 対象者UUIDによる評価者（一人）の呼び出し
    func loadAssessor(targetPersonUUID: UUID) -> Assessor? {
        guard let fetchedTargetPerson = realm.object(
            ofType: TargetPerson.self,
            forPrimaryKey: targetPersonUUID.uuidString
        ) else { return nil }
        return fetchedTargetPerson.assessors.first
    }
    //　評価者の追加
    func apppendAssessor(assesor: Assessor) {
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.add(assesor)
        }
    }
    // 評価者の更新
    func updateAssessor(uuid: UUID, name: String) {
        // swiftlint:disable:next force_cast
        try! realm.write {
            let assessor = realm.object(ofType: Assessor.self, forPrimaryKey: uuid.uuidString)
            assessor?.name = name
        }
    }
    // 評価者の削除
    func removeAssessor(uuid: UUID) {
        guard let assessor = realm.object(ofType: Assessor.self, forPrimaryKey: uuid.uuidString) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(assessor)
        }
    }

    // MARK: - TargetPersonRepository
    // 一人の評価者が評価するor評価した、対象者の配列の呼び出し
    func loadTargetPerson(assessorUUID: UUID) -> [TargetPerson] {
        let assessor = realm.object(ofType: Assessor.self, forPrimaryKey: assessorUUID.uuidString)
        guard let targetPersons = assessor?.targetPersons else { return [] }
        let targetPersonsArray = Array(targetPersons)
        return targetPersonsArray
    }
    // 一人の対象者のUUIDから、一人の対象者の呼び出し
    func loadTargetPerson(targetPersonUUID: UUID) -> TargetPerson? {
        let targetPerson = realm.object(ofType: TargetPerson.self, forPrimaryKey: targetPersonUUID.uuidString)
        return targetPerson
    }

    // 一つのFIMのUUIDから、そのFIMがどの対象者かの呼び出し
    func loadTargetPerson(fimUUID: UUID) -> TargetPerson? {
        guard let fetchedFIM = realm.object(ofType: FIM.self, forPrimaryKey: fimUUID.uuidString) else { return nil }
        return fetchedFIM.targetPersons.first
    }
    //  一人の評価者の対象者の追加
    func appendTargetPerson(assessorUUID: UUID, targetPerson: TargetPerson) {
        guard let list = realm.object(
            ofType: Assessor.self,
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
            let targetPerson = realm.object(ofType: TargetPerson.self, forPrimaryKey: uuid.uuidString)
            targetPerson?.name = name
        }
    }
    // 一人の対象者のデータ削除
    func removeTargetPerson(targetPersonUUID: UUID) {
        guard let fetchedTagetPerson = realm.object(
            ofType: TargetPerson.self,
            forPrimaryKey: targetPersonUUID.uuidString
        ) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(fetchedTagetPerson)
        }
    }

    // MARK: - FIMRepository
    // 一つのFIMのUUIDから、FIMのデータの呼び出し
    func loadFIM(fimUUID: UUID) -> FIM? {
        let fim = realm.object(ofType: FIM.self, forPrimaryKey: fimUUID.uuidString)
        return fim
    }
    //　一人の対象者のUUIDから、複数のFIMのデータの呼び出し(並び替えあり)
    func loadFIM(
        targetPersonUUID: UUID,
        sortedAscending: Bool
    ) -> [FIM] {
        let fimList = realm.object(
            ofType: TargetPerson.self,
            forPrimaryKey: targetPersonUUID.uuidString
        )?.FIM.sorted(
            byKeyPath: "createdAt",
            ascending: sortedAscending
        )
        guard let fimList = fimList else { return [] }
        let fimListArray = Array(fimList)
        return fimListArray
    }
    //  一人の対象者のFIMデータの追加
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
    // FIMデータの更新
    // 【気になる点】
    // データ更新の項目数が多く、一つのモデルオブジェクト（Realmだから、モデルオブジェクト？構造体ではなく？）にまとめて、そのデータを代入して
    //　FIMの値を更新しようと試みたが、書き換えた　FIM　を引数として、代入すると、更新ができない。
    // REONさんに、助言を頂きましたが、その解決策がわかりませんでした。
    // realm.writeの中で、データを書き換えなければならず、どのように実装すればよいかがわからなかった。

    // 私の方法・・・項目ごとの結果を引数に渡して、realm.write内で、更新データを取り出して、代入する。
    //　→私の方法であれば、項目数が増えてしまい、今後コードを修正に困る、というデメリットがあります。

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
    // FIMデータの削除
    func removeFIM(fimUUID: UUID) {
        guard let fetchedFIM = realm.object(ofType: FIM.self, forPrimaryKey: fimUUID.uuidString) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(fetchedFIM)
        }
    }
}
