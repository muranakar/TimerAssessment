//
//  PastAssessmentViewController.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/01.
//

import UIKit

class PastAssessmentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //　画面遷移で値を受け取る変数
    var assessmentItem: AssessmentItem?

    // 画面遷移先へ値を渡す変数
    var selectedTimerAssessment: TimerAssessment?
    var editingTimerAssessment: TimerAssessment?

    //　並び替えのための変数
    private var isSortedAscending = false

    private let timerAssessmentRepository = TimerAssessmentRepository()

    private var targetPerson: TargetPerson? {
        guard let assessmentItem = assessmentItem else {
            return nil
        }
        return timerAssessmentRepository.loadTargetPerson(assessmentItem: assessmentItem)
    }

    // MARK: - IBOutlet
    @IBOutlet weak private var assessmentItemNameLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let targetPersonName =  targetPerson?.name else {
            fatalError("targetPersonの中身がない。メソッド名：[\(#function)]")
        }
        navigationItem.title = "対象者:　\(targetPersonName)　様"
        assessmentItemNameLabel.text = assessmentItem!.name
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            UINib(nibName: "PastAssessmentTableViewCell", bundle: nil),
            forCellReuseIdentifier: "pastAssessmentTableViewCell"
        )
        tableView.reloadData()
        configueViewNavigationbarColor()
    }

    // MARK: - Segue- FIMTableViewController →　InputTargetPersonViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        guard let nav = segue.destination as? UINavigationController else { return }
        //        if let detailFIMVC = nav.topViewController as? DetailFIMViewController {
        //            switch segue.identifier ?? "" {
        //            case "detailFIM":
        //                detailFIMVC.fimUUID = selectedFIMUUID
        //                // このmodeによって、画面遷移先の次の画面遷移先を決めている。
        //                detailFIMVC.mode = .fim
        //            default:
        //                break
        //            }
        //        }
    }

    // MARK: - Segue- PastAssessmentTableViewController ←　InputAssessmentViewController
    @IBAction private func backToPastAssessmentTableViewController(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    // MARK: - Segue- SortTableView
    // MARK: - ーーーーーーーーーーーーー ここまで完成　ーーーーーーーーーーーーーーーーーーーーーーー
    @IBAction private func sortTableView(_ sender: Any) {
        isSortedAscending.toggle()
        tableView.reloadData()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        timerAssessmentRepository
            .loadTimerAssessment(
                assessmentItem: assessmentItem!,
                sortedAscending: isSortedAscending
            ).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "pastAssessmentTableViewCell"
        ) as! PastAssessmentTableViewCell
        let timerAssessment = timerAssessmentRepository.loadTimerAssessment(
            assessmentItem: assessmentItem!,
            sortedAscending: isSortedAscending
        )[indexPath.row]

        var createdAtString = "--"
        if let createdAt = timerAssessment.createdAt {
            createdAtString  = createdAtdateFormatter(date: createdAt)
        }

        cell.configure(
            timerResultNumLabelString: resultTimerStringFormatter(resultTimer: timerAssessment.resultTimer),
            createdAtLabelString: createdAtString,
            copyAssessmentTextHandler: {
                UIPasteboard.general.string =
                CopyAndPasteFunctionAssessment(timerAssessment: timerAssessment).copyAndPasteString
                // MARK: - weak selfを行うべきなのか、そうではないのか。
                self.copyButtonPushAlert(title: "コピー完了", message: "FIMデータ内容のコピーが\n完了しました。")
            }
        )
        return cell
    }

    //    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        selectedFIMUUID = fimRepository.loadFIM(
    //            targetPersonUUID: targetPersonUUID!,
    //            sortedAscending: isSortedAscending
    //        )[indexPath.row].uuid
    //        toDetailFIMViewController()
    //    }
    //
    //    //　navのボタンへの変更必要か。
    //    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    //        editingFIMUUID = fimRepository.loadFIM(
    //            targetPersonUUID: targetPersonUUID!,
    //            sortedAscending: false
    //        )[indexPath.row].uuid
    //
    //        performSegue(withIdentifier: "edit", sender: nil)
    //    }
    //
    //    override func tableView(_ tableView: UITableView,
    //                            commit editingStyle: UITableViewCell.EditingStyle,
    //                            forRowAt indexPath: IndexPath) {
    //        guard editingStyle == .delete else { return }
    //        guard let uuid = fimRepository.loadFIM(
    //            targetPersonUUID: targetPersonUUID!,
    //            sortedAscending: isSortedAscending
    //        )[indexPath.row].uuid else { return }
    //        fimRepository.removeFIM(fimUUID: uuid)
    //        tableView.reloadData()
    //    }
    // MARK: - Method
    private func toDetailAssessmentViewController() {
        //        let storyboard = UIStoryboard(name: "DetailFIM", bundle: nil)
        //        let nextVC =
        //        storyboard.instantiateViewController(withIdentifier: "detailFIM") as! DetailFIMViewController
        //        nextVC.fimUUID = selectedFIMUUID
        //        nextVC.mode = .fim
        //        navigationController?.pushViewController(nextVC, animated: true)
    }
    // MARK: - UIAlertController
    func copyButtonPushAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    // MARK: - Formatter　Double・Date型→String型へ変更
    func resultTimerStringFormatter(resultTimer: Double) -> String {
        // 整数部分
        let integer = Int(resultTimer)
        // 小数部分
        let fraction = resultTimer.truncatingRemainder(dividingBy: 1)

        var string = ""
        var isHour = false

        let hour = integer / 3600
        if hour > 0 {
            string += "\(hour):"
            isHour = true
        }

        let min = integer / 60
        if isHour || min > 0 {
            string += "\(min):"
        }

        let sec = integer % 60
        string += "\(sec):"

        let fracitonConversion = Int(fraction * 100)
        string += "\(fracitonConversion)"
        return string
    }
    func createdAtdateFormatter(date: Date) -> String {
        let dateFormatter = Foundation.DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "yyyy'年'MM'月'dd'日'　HH'時'mm'分'"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
