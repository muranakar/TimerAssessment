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
    private var sortType: SortType = .dateDescending

    enum SortType {
        case dateAscending   // 日付: 古い順
        case dateDescending  // 日付: 新しい順
        case timeAscending   // タイム: 速い順
        case timeDescending  // タイム: 遅い順

        var displayName: String {
            switch self {
            case .dateAscending: return "日付: 古い順"
            case .dateDescending: return "日付: 新しい順"
            case .timeAscending: return "タイム: 速い順"
            case .timeDescending: return "タイム: 遅い順"
            }
        }

        var iconName: String {
            switch self {
            case .dateAscending: return "calendar.badge.clock"
            case .dateDescending: return "calendar.badge.clock"
            case .timeAscending: return "timer"
            case .timeDescending: return "timer"
            }
        }
    }

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
    @IBOutlet weak private var assessmentItemTitleView: UIView!

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

        // 戻るボタンをプログラムで設定
        setupNavigationBar()

        tableView.reloadData()
        configueViewNavigationbarColor()
        configureViewAssessmentItemTitleView()
    }

    private func setupNavigationBar() {
        // 左側: 戻るボタン
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "戻る",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )

        // 右側: ソートボタン
        let sortButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down.circle"),
            style: .plain,
            target: self,
            action: #selector(showSortMenu)
        )
        navigationItem.rightBarButtonItem = sortButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func showSortMenu() {
        let alert = UIAlertController(
            title: "並び替え",
            message: "並び替え方法を選択してください",
            preferredStyle: .actionSheet
        )

        // 日付: 新しい順
        alert.addAction(UIAlertAction(
            title: sortType == .dateDescending ? "✓ 日付: 新しい順" : "日付: 新しい順",
            style: .default,
            handler: { [weak self] _ in
                self?.changeSortType(.dateDescending)
            }
        ))

        // 日付: 古い順
        alert.addAction(UIAlertAction(
            title: sortType == .dateAscending ? "✓ 日付: 古い順" : "日付: 古い順",
            style: .default,
            handler: { [weak self] _ in
                self?.changeSortType(.dateAscending)
            }
        ))

        // タイム: 速い順
        alert.addAction(UIAlertAction(
            title: sortType == .timeAscending ? "✓ タイム: 速い順" : "タイム: 速い順",
            style: .default,
            handler: { [weak self] _ in
                self?.changeSortType(.timeAscending)
            }
        ))

        // タイム: 遅い順
        alert.addAction(UIAlertAction(
            title: sortType == .timeDescending ? "✓ タイム: 遅い順" : "タイム: 遅い順",
            style: .default,
            handler: { [weak self] _ in
                self?.changeSortType(.timeDescending)
            }
        ))

        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))

        // iPadのためのpopover設定
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }

        present(alert, animated: true)
    }

    private func changeSortType(_ newType: SortType) {
        sortType = newType
        tableView.reloadData()

        // フィードバック
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    // MARK: - Segue- PastAssessmentTableViewController ←　InputAssessmentViewController
    @IBAction private func backToPastAssessmentTableViewController(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    // MARK: - Segue- SortTableView
    @IBAction private func sortTableView(_ sender: Any) {
        // 古い実装を残す（Storyboardから呼ばれる可能性があるため）
        showSortMenu()
    }

    // ソートされたデータを取得
    private func loadSortedTimerAssessments() -> [TimerAssessment] {
        guard let assessmentItem = assessmentItem else { return [] }

        switch sortType {
        case .dateAscending:
            return timerAssessmentRepository.loadTimerAssessment(
                assessmentItem: assessmentItem,
                sortBy: "createdAt",
                ascending: true
            )
        case .dateDescending:
            return timerAssessmentRepository.loadTimerAssessment(
                assessmentItem: assessmentItem,
                sortBy: "createdAt",
                ascending: false
            )
        case .timeAscending:
            return timerAssessmentRepository.loadTimerAssessment(
                assessmentItem: assessmentItem,
                sortBy: "resultTimer",
                ascending: true
            )
        case .timeDescending:
            return timerAssessmentRepository.loadTimerAssessment(
                assessmentItem: assessmentItem,
                sortBy: "resultTimer",
                ascending: false
            )
        }
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        loadSortedTimerAssessments().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "pastAssessmentTableViewCell",
            for: indexPath
        ) as! PastAssessmentTableViewCell
        let timerAssessment = loadSortedTimerAssessments()[indexPath.row]

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
        let timerAssessment = loadSortedTimerAssessments()[indexPath.row]
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
        appearance.backgroundColor = UIColor(named: "navigation")!
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
    private func configureViewAssessmentItemTitleView() {
        assessmentItemTitleView.backgroundColor = UIColor(named: "navigation")!
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
