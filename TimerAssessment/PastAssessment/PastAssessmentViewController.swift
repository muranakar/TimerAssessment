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

    // 複数選択モード
    private var isEditingMode = false
    private var selectedIndexPaths: Set<IndexPath> = []

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

    // MARK: - Statistics Header View
    private var statisticsHeaderView: UIView?

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

    private func createStatisticsHeaderView() -> UIView {
        let assessments = loadSortedTimerAssessments()

        let headerView = UIView()
        headerView.backgroundColor = .secondarySystemGroupedBackground

        // コンパクトな2列レイアウト
        let containerStack = UIStackView()
        containerStack.axis = .vertical
        containerStack.spacing = 8
        containerStack.translatesAutoresizingMaskIntoConstraints = false

        // 1行目: 平均と記録数
        let topStack = UIStackView()
        topStack.axis = .horizontal
        topStack.distribution = .fillEqually
        topStack.spacing = 8

        // 2行目: 最速と最遅
        let bottomStack = UIStackView()
        bottomStack.axis = .horizontal
        bottomStack.distribution = .fillEqually
        bottomStack.spacing = 8

        if !assessments.isEmpty {
            let times = assessments.map { $0.resultTimer }
            let average = times.reduce(0, +) / Double(times.count)
            let fastest = times.min() ?? 0
            let slowest = times.max() ?? 0

            topStack.addArrangedSubview(createStatCard(title: "平均", value: resultTimerStringFormatter(resultTimer: average), icon: "📊"))
            topStack.addArrangedSubview(createStatCard(title: "記録数", value: "\(assessments.count)件", icon: "📝"))

            bottomStack.addArrangedSubview(createStatCard(title: "最速", value: resultTimerStringFormatter(resultTimer: fastest), icon: "⚡"))
            bottomStack.addArrangedSubview(createStatCard(title: "最遅", value: resultTimerStringFormatter(resultTimer: slowest), icon: "🐢"))
        } else {
            topStack.addArrangedSubview(createStatCard(title: "平均", value: "--", icon: "📊"))
            topStack.addArrangedSubview(createStatCard(title: "記録数", value: "0件", icon: "📝"))

            bottomStack.addArrangedSubview(createStatCard(title: "最速", value: "--", icon: "⚡"))
            bottomStack.addArrangedSubview(createStatCard(title: "最遅", value: "--", icon: "🐢"))
        }

        containerStack.addArrangedSubview(topStack)
        containerStack.addArrangedSubview(bottomStack)

        headerView.addSubview(containerStack)

        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            containerStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            containerStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            containerStack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])

        return headerView
    }

    private func createStatCard(title: String, value: String, icon: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 8
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowOffset = CGSize(width: 0, height: 1)
        card.layer.shadowRadius = 2

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 20)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 11, weight: .medium)
        titleLabel.textColor = .secondaryLabel

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        valueLabel.textColor = .label
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.8

        stack.addArrangedSubview(iconLabel)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(valueLabel)

        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8),
            card.heightAnchor.constraint(equalToConstant: 70)
        ])

        return card
    }

    private func setupNavigationBar() {
        updateNavigationBar()
    }

    private func updateNavigationBar() {
        if isEditingMode {
            // 編集モード時
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "キャンセル",
                style: .plain,
                target: self,
                action: #selector(cancelEditMode)
            )

            // 右側: 共有とコピーボタン
            let shareButton = UIBarButtonItem(
                image: UIImage(systemName: "square.and.arrow.up"),
                style: .plain,
                target: self,
                action: #selector(shareSelectedItems)
            )
            let copyButton = UIBarButtonItem(
                image: UIImage(systemName: "doc.on.doc"),
                style: .plain,
                target: self,
                action: #selector(copySelectedItems)
            )
            navigationItem.rightBarButtonItems = [shareButton, copyButton]
        } else {
            // 通常モード時
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "戻る",
                style: .plain,
                target: self,
                action: #selector(backButtonTapped)
            )

            // 右側: ソートと選択ボタン
            let sortButton = UIBarButtonItem(
                image: UIImage(systemName: "arrow.up.arrow.down.circle"),
                style: .plain,
                target: self,
                action: #selector(showSortMenu)
            )
            let selectButton = UIBarButtonItem(
                title: "選択",
                style: .plain,
                target: self,
                action: #selector(enterEditMode)
            )
            navigationItem.rightBarButtonItems = [sortButton, selectButton]
        }
    }

    @objc private func enterEditMode() {
        isEditingMode = true
        selectedIndexPaths.removeAll()
        tableView.allowsMultipleSelection = true
        updateNavigationBar()
        tableView.reloadData()
    }

    @objc private func cancelEditMode() {
        isEditingMode = false
        selectedIndexPaths.removeAll()
        tableView.allowsMultipleSelection = false
        updateNavigationBar()
        tableView.reloadData()
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func shareSelectedItems() {
        guard !selectedIndexPaths.isEmpty else {
            showAlert(title: "選択してください", message: "共有するデータを選択してください。")
            return
        }

        let selectedData = getSelectedTimerAssessments()
        let textToShare = formatTimerAssessmentsForSharing(selectedData)

        let activityVC = UIActivityViewController(
            activityItems: [textToShare],
            applicationActivities: nil
        )

        // iPadのためのpopover設定
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItems?.first
        }

        present(activityVC, animated: true)
    }

    @objc private func copySelectedItems() {
        guard !selectedIndexPaths.isEmpty else {
            showAlert(title: "選択してください", message: "コピーするデータを選択してください。")
            return
        }

        let selectedData = getSelectedTimerAssessments()
        let textToCopy = formatTimerAssessmentsForSharing(selectedData)

        UIPasteboard.general.string = textToCopy

        showAlert(title: "コピー完了", message: "\(selectedData.count)件のデータをコピーしました。")
    }

    private func getSelectedTimerAssessments() -> [TimerAssessment] {
        let sortedIndexPaths = selectedIndexPaths.sorted { $0.row < $1.row }
        let allData = loadSortedTimerAssessments()
        return sortedIndexPaths.compactMap { indexPath in
            guard indexPath.row < allData.count else { return nil }
            return allData[indexPath.row]
        }
    }

    private func formatTimerAssessmentsForSharing(_ assessments: [TimerAssessment]) -> String {
        guard let assessmentItem = assessmentItem,
              let targetPerson = targetPerson else {
            return ""
        }

        var text = "【\(assessmentItem.name)】\n"
        text += "対象者: \(targetPerson.name)\n\n"

        for (index, assessment) in assessments.enumerated() {
            let resultString = resultTimerStringFormatter(resultTimer: assessment.resultTimer)
            let dateString: String
            if let createdAt = assessment.createdAt {
                dateString = createdAtdateFormatter(date: createdAt)
            } else {
                dateString = "--"
            }
            text += "\(index + 1). \(resultString) (\(dateString))\n"
        }

        return text
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = createStatisticsHeaderView()
        statisticsHeaderView = headerView
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 164 // 8 (上) + 70 (上段) + 8 (間隔) + 70 (下段) + 8 (下) = 164
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // メモがある場合は高さを増やす
        let timerAssessment = loadSortedTimerAssessments()[indexPath.row]
        if let memo = timerAssessment.memo, !memo.isEmpty {
            return 100 // メモがある場合は高さを増やす
        }
        return 80
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
            memo: timerAssessment.memo,
            copyAssessmentTextHandler: {[weak self] in
                UIPasteboard.general.string =
                CopyAndPasteFunctionAssessment(timerAssessment: timerAssessment).copyAndPasteString
                self?.copyButtonPushAlert(title: "コピー完了", message: "データ内容のコピーが\n完了しました。")
            },
            shareAssessmentTextHandler: {[weak self] in
                self?.shareAssessment(timerAssessment)
            }
        )

        // 編集モード時の選択表示
        if isEditingMode {
            if selectedIndexPaths.contains(indexPath) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if isEditingMode {
            // 編集モード: 選択/解除をトグル
            if selectedIndexPaths.contains(indexPath) {
                selectedIndexPaths.remove(indexPath)
            } else {
                selectedIndexPaths.insert(indexPath)
            }
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    private func shareAssessment(_ assessment: TimerAssessment) {
        let textToShare = CopyAndPasteFunctionAssessment(timerAssessment: assessment).copyAndPasteString

        let activityVC = UIActivityViewController(
            activityItems: [textToShare],
            applicationActivities: nil
        )

        // iPadのためのpopover設定
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        present(activityVC, animated: true)
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
