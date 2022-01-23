//
//  FIMTableViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit
import Foundation

final class FIMTableViewController: UITableViewController {
    //　画面遷移で値を受け取る変数
    var targetPersonUUID: UUID?

    // 画面遷移先へ値を渡す変数
    var selectedFIMUUID: UUID?
    var editingFIMUUID: UUID?

    //　並び替えのための変数
    private var isSortedAscending = false

    let fimRepository = FIMRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let targetPersonName =  fimRepository.loadTargetPerson(targetPersonUUID: targetPersonUUID!)?.name else {
            return
        }
        navigationItem.title = "対象者:　\(targetPersonName)　様"
        tableView.register(UINib(nibName: "FIMTableViewCell", bundle: nil), forCellReuseIdentifier: "FIMTableViewCell")
        tableView.reloadData()
        configueViewNavigationbarColor()
    }

    // MARK: - Segue- FIMTableViewController →　InputTargetPersonViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController else { return }
        if let detailFIMVC = nav.topViewController as? DetailFIMViewController {
            switch segue.identifier ?? "" {
            case "detailFIM":
                detailFIMVC.fimUUID = selectedFIMUUID
                // このmodeによって、画面遷移先の次の画面遷移先を決めている。
                detailFIMVC.mode = .fim
            default:
                break
            }
        }
    }

    // MARK: - Segue- FIMTableViewController ←　InputFIMViewController
    @IBAction private func backToFIMTableViewController(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    // MARK: - Segue- SortTableView

    @IBAction private func sortTableView(_ sender: Any) {
        isSortedAscending.toggle()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fimRepository.loadFIM(
            targetPersonUUID: targetPersonUUID!,
            sortedAscending: isSortedAscending
        ).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "FIMTableViewCell") as! FIMTableViewCell
        let fim = fimRepository.loadFIM(
            targetPersonUUID: targetPersonUUID!,
            sortedAscending: isSortedAscending
        )[indexPath.row]
        guard let targetPerson = fimRepository.loadTargetPerson(fimUUID: fim.uuid!) else {
            fatalError()
        }
        guard let assessor = fimRepository.loadAssessor(targetPersonUUID: targetPerson.uuid!) else { fatalError()}
        var createdAtString = "--"
        var updateAtString = "--"
        if let createdAt = fim.createdAt {
            createdAtString  = dateFormatter(date: createdAt)
        }
        if let updateAt = fim.updatedAt {
            updateAtString = dateFormatter(date: updateAt)
        }

        cell.configure(
            fim: fim,
            createdAt: createdAtString,
            updatedAt: updateAtString,
            copyFIMTextHandler: {
                UIPasteboard.general.string =
                // swiftlint:disable:next line_length
                "FIM評価結果\n評価日\(createdAtString)\n評価者:\(assessor.name)\n対象者:\(targetPerson.name)\n合計値\(fim.sumAll)\n食事:\(fim.eating)\n整容:\(fim.grooming)\n清拭:\(fim.bathing)\n更衣上半身:\(fim.dressingUpperBody)\n更衣下半身:\(fim.dressingLowerBody)\nトイレ動作:\(fim.toileting)\n排尿管理:\(fim.bladderManagement)\n排便管理:\(fim.bowelManagement)\nベッド・椅子・車椅子移乗:\(fim.transfersBedChairWheelchair)\nトイレ移乗:\(fim.transfersToilet)\n浴槽・シャワー移乗:\(fim.transfersBathShower)\n歩行・車椅子:\(fim.walkWheelchair)\n階段:\(fim.stairs)\n理解:\(fim.comprehension)\n表出:\(fim.expression)\n社会的交流:\(fim.socialInteraction)\n問題解決:\(fim.problemSolving)\n記憶:\(fim.memory)"
            })
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFIMUUID = fimRepository.loadFIM(
            targetPersonUUID: targetPersonUUID!,
            sortedAscending: isSortedAscending
        )[indexPath.row].uuid
        toDetailFIMViewController()
    }

    //　navのボタンへの変更必要か。
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editingFIMUUID = fimRepository.loadFIM(
            targetPersonUUID: targetPersonUUID!,
            sortedAscending: false
        )[indexPath.row].uuid

        performSegue(withIdentifier: "edit", sender: nil)
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let uuid = fimRepository.loadFIM(
            targetPersonUUID: targetPersonUUID!,
            sortedAscending: isSortedAscending
        )[indexPath.row].uuid else { return }
        fimRepository.removeFIM(fimUUID: uuid)
        tableView.reloadData()
    }
    // MARK: - Method
    private func toDetailFIMViewController() {
        let storyboard = UIStoryboard(name: "DetailFIM", bundle: nil)
        let nextVC =
        storyboard.instantiateViewController(withIdentifier: "detailFIM") as! DetailFIMViewController
        nextVC.fimUUID = selectedFIMUUID
        nextVC.mode = .fim
        navigationController?.pushViewController(nextVC, animated: true)
    }
    // MARK: - View Configue
    private func configueViewNavigationbarColor() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.baseColor
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
    // MARK: - DateFormatter　Date型→String型へ変更
    func dateFormatter(date: Date) -> String {
        let dateFormatter = Foundation.DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
