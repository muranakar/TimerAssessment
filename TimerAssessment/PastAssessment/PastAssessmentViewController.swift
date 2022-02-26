//
//  PastAssessmentViewController.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/01.
//

import UIKit

final class PastAssessmentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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

    // MARK: - Segue- PastAssessmentTableViewController ←　InputAssessmentViewController
    @IBAction private func backToPastAssessmentTableViewController(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    // MARK: - Segue- SortTableView
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
            copyAssessmentTextHandler: {[weak self] in
                UIPasteboard.general.string =
                CopyAndPasteFunctionAssessment(timerAssessment: timerAssessment).copyAndPasteString
                // MARK: - weak selfを行うべきなのか、そうではないのか。
                self?.copyButtonPushAlert(title: "コピー完了", message: "データ内容のコピーが\n完了しました。")
            }
        )
        return cell
    }
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let timerAssessment = timerAssessmentRepository.loadTimerAssessment(
            assessmentItem: assessmentItem!,
            sortedAscending: isSortedAscending
        )[indexPath.row]
        timerAssessmentRepository.removeTimerAssessment(timerAssessment: timerAssessment)
        tableView.reloadData()
    }
    // MARK: - UIAlertController
    private func copyButtonPushAlert(title: String, message: String) {
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
    private func resultTimerStringFormatter(resultTimer: Double) -> String {
        // 整数部分
        let integer = Int(resultTimer)
        // 小数部分
        let fraction = resultTimer.truncatingRemainder(dividingBy: 1)

        var string = ""
        let hour = integer / 3600
        let min = integer / 60
        let sec = integer % 60
        let fracitonConversion = Int(fraction * 100)
        // １時間以上経過していた場合
        if hour > 0 {
            string = String(format: "%02d時%02d分%02d秒%02d", hour, min, sec, fracitonConversion)
            return string
        }
        // １分以上経過していた場合
        if min > 0 {
            string = String(format: "%02d分%02d秒%02d", min, sec, fracitonConversion)
            return string
        }
        // １分未満の場合
        string = String(format: "%02d秒%02d", sec, fracitonConversion)
        return string
    }

    private func createdAtdateFormatter(date: Date) -> String {
        let dateFormatter = Foundation.DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "yyyy'年'MM'月'dd'日'　HH'時'mm'分'"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
