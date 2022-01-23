//
//  FIMViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

class FIMViewController: UIViewController {
    //　画面遷移で値を受け取る変数
    var fimUUID: UUID?
    private let fimRepository = FIMRepository()

    private var fim: FIM {
        let fim = fimRepository.loadFIM(fimUUID: fimUUID!)
        guard let fim = fim else {
            fatalError("fimの値が入っていない")
        }
        return fim
    }

    private var fimItemNum: [Int] {
        [
            fim.sumAll,
            fim.sumTheMotorSubscaleIncludes,
            fim.eating,
            fim.grooming,
            fim.bathing,
            fim.dressingUpperBody,
            fim.dressingLowerBody,
            fim.toileting,
            fim.bladderManagement,
            fim.bowelManagement,
            fim.transfersBedChairWheelchair,
            fim.transfersToilet,
            fim.transfersBathShower,
            fim.walkWheelchair,
            fim.stairs,
            fim.sumTheCognitionSubscaleIncludes,
            fim.comprehension,
            fim.expression,
            fim.socialInteraction,
            fim.problemSolving,
            fim.memory
        ]
    }

    private var fimItemTitle: [String] {
        [
            "総合計", "運動項目合計", "食事", "整容", "清拭",
            "更衣上半身", "更衣下半身", "トイレ動作", "排尿管理",
            "排便管理", "ベッド・椅子・車椅子移乗", "トイレ移乗",
            "浴槽・シャワー移乗", "歩行・車椅子", "階段",
            "認知項目合計", "理解", "表出", "社会的交流", "問題解決", "記憶"
        ]
    }
    // なくても良い
    private var dictionaryFIMItemAndNum: [String: Int] {
        [String: Int](uniqueKeysWithValues: zip(fimItemTitle, fimItemNum))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = String(fim.sumAll)
    }
}

extension FIMViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dictionaryFIMItemAndNum.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DetailFIMTableViewCell
        // swiftlint:disable:next force_cast
        let boldTextcell = tableView.dequeueReusableCell(withIdentifier: "cellBold") as! DetailTextBoldFIMTableViewCell

        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 15 {
            boldTextcell.configure(
                fimItemTitle: fimItemTitle[indexPath.row],
                fimItemNum: String(fimItemNum[indexPath.row])
            )
            return boldTextcell
        } else {
            cell.configure(
                fimItemTitle: fimItemTitle[indexPath.row] ,
                fimItemNum: String(fimItemNum[indexPath.row])
            )
            return cell
        }
    }
}
