//
//  EditFIMTableViewController.swift
//  FunctionalIndependenceMeasure
//
//  Created by 村中令 on 2021/12/29.
//

import UIKit

final class EditFIMTableViewController: UITableViewController {
    //　画面遷移で値を受け取る変数
    var fimUUID: UUID!
    let fimRepository = FIMRepository()

    private var fim: FIM {
        let fim = fimRepository.loadFIM(fimUUID: fimUUID!)
        guard let fim = fim else { fatalError("fimの値が入っていない。メソッド名：[\(#function)]")}
        return fim
    }

    private lazy var fimItemTitle: [String] =
        [
            "食事", "整容", "清拭",
            "更衣上半身", "更衣下半身", "トイレ動作", "排尿管理",
            "排便管理", "ベッド・椅子・車椅子移乗", "トイレ移乗",
            "浴槽・シャワー移乗", "歩行・車椅子", "階段",
            "理解", "表出", "社会的交流", "問題解決", "記憶"
        ]
    // TableViewCellに表示するためだけの配列
    private lazy var fimItemNum: [Int] =
    [
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
        fim.comprehension,
        fim.expression,
        fim.socialInteraction,
        fim.problemSolving,
        fim.memory
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let targetPersonName =  fimRepository.loadTargetPerson(fimUUID: fimUUID!)?.name else {
            return
        }
        navigationItem.title = "対象者:　\(targetPersonName)　様"
        configueViewNavigationbarColor()
    }
    @IBAction private func save(_ sender: Any) {
        fimRepository.updateFIM(fimItemNumArray: fimItemNum, fimUUID: fimUUID!)
        performSegue(withIdentifier: "save", sender: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fimItemTitle.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EditFIMTableViewCell
        cell.configue(labelText: fimItemTitle[indexPath.row],
                      textFieldText: String(fimItemNum[indexPath.row]),
                      updateFIMNumHandler: { [weak self] element in
            self?.fimItemNum[indexPath.row] = element
        })
        return cell
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
}
