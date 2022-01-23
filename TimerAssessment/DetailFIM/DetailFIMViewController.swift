//
//  DetailFIMViewController.swift
//  FunctionalIndependenceMeasure
//
//  Created by 村中令 on 2021/12/24.
//

import UIKit

final class DetailFIMViewController: UIViewController {
    //　画面遷移で値を受け取る変数
    var fimUUID: UUID?
    // サンプル　後で消す
    var count: String?

    // どの画面から遷移したかによって、unwindSegueの画面遷移先を、変更する。
    enum Mode {
        case assessment
        case fim
    }
    var mode: Mode?

    private let fimRepository = FIMRepository()

    private var fim: FIM {
        let fim = fimRepository.loadFIM(fimUUID: fimUUID!)
        guard let fim = fim else { fatalError("fimの値が入っていない。メソッド名：[\(#function)]")}
        return fim
    }

    struct FIMItem {
        let title: String
        let point: Int
    }

    private lazy var fimItems: [FIMItem] = [
        FIMItem(title: "総合計", point: fim.sumAll),
        FIMItem(title: "運動項目合計", point: fim.sumTheMotorSubscaleIncludes),
        FIMItem(title: "食事", point: fim.eating),
        FIMItem(title: "整容", point: fim.grooming),
        FIMItem(title: "清拭", point: fim.bathing),
        FIMItem(title: "更衣上半身", point: fim.dressingUpperBody),
        FIMItem(title: "更衣下半身", point: fim.dressingUpperBody),
        FIMItem(title: "トイレ動作", point: fim.toileting),
        FIMItem(title: "排尿管理", point: fim.bladderManagement),
        FIMItem(title: "排便管理", point: fim.bowelManagement),
        FIMItem(title: "ベッド・椅子・車椅子移乗", point: fim.transfersBedChairWheelchair),
        FIMItem(title: "トイレ移乗", point: fim.transfersToilet),
        FIMItem(title: "浴槽・シャワー移乗", point: fim.transfersBathShower),
        FIMItem(title: "歩行・車椅子", point: fim.walkWheelchair),
        FIMItem(title: "階段", point: fim.stairs),
        FIMItem(title: "認知項目合計", point: fim.sumTheCognitionSubscaleIncludes),
        FIMItem(title: "理解", point: fim.comprehension),
        FIMItem(title: "表出", point: fim.expression),
        FIMItem(title: "社会的交流", point: fim.socialInteraction),
        FIMItem(title: "問題解決", point: fim.problemSolving),
        FIMItem(title: "記憶", point: fim.memory)
    ]
    @IBOutlet weak private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let targetPersonName =  fimRepository.loadTargetPerson(fimUUID: fimUUID!)?.name else {
            return
        }
        navigationItem.title = "対象者:　\(targetPersonName)　様"
        tableView.delegate = self
        tableView.dataSource = self
        configueViewNavigationbarColor()
    }

    @IBAction private func editFIM(_ sender: Any) {
        performSegue(withIdentifier: "editFIM", sender: nil)
    }

    @IBAction private func back(_ sender: Any) {
        switch mode {
        case .assessment:
            performSegue(withIdentifier: "functionSelection", sender: nil)
        case .fim:
            performSegue(withIdentifier: "fim", sender: nil)
        default:
            break
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController else { return }
        if let editVC = nav.topViewController as? EditFIMTableViewController {
            switch segue.identifier ?? "" {
            case "editFIM":
                editVC.fimUUID = fimUUID
            default:
                break
            }
        }
    }

    @IBAction private func backToDetailFIMViewController(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }
}

extension DetailFIMViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fimItems.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DetailFIMTableViewCell
        // swiftlint:disable:next force_cast
        let boldTextcell = tableView.dequeueReusableCell(withIdentifier: "cellBold") as! DetailTextBoldFIMTableViewCell

        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 15 {
            boldTextcell.configure(
                fimItemTitle: fimItems[indexPath.row].title,
                fimItemNum: String(fimItems[indexPath.row].point)
            )
            boldTextcell.backgroundColor = Colors.mainColor.withAlphaComponent(0.1)
            return boldTextcell
        } else {
            cell.configure(
                fimItemTitle: fimItems[indexPath.row].title ,
                fimItemNum: String(fimItems[indexPath.row].point)
            )
            return cell
        }
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
