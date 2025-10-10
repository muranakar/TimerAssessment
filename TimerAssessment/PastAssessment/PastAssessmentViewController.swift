//
//  PastAssessmentViewController.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/01.
//

import UIKit

final class PastAssessmentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
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

    // 検索機能
    private var searchText: String = ""
    private var isSearching: Bool {
        return !searchText.isEmpty
    }

    // 統計サマリーの表示状態
    private var isStatisticsExpanded = true

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

    // MARK: - Header Views
    private var statisticsHeaderView: UIView?

    // 検索バー（Viewに直接配置）
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "メモを検索"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    // 検索バーのコンテナ
    private let searchBarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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
        setupSearchBar()

        tableView.reloadData()
        configueViewNavigationbarColor()
        configureViewAssessmentItemTitleView()
    }

    private func setupSearchBar() {
        searchBar.delegate = self

        // 検索バーをViewに直接追加（TableViewの外側）
        view.addSubview(searchBarContainer)
        searchBarContainer.addSubview(searchBar)

        NSLayoutConstraint.activate([
            // 検索バーコンテナの配置
            searchBarContainer.topAnchor.constraint(equalTo: assessmentItemTitleView.bottomAnchor),
            searchBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBarContainer.heightAnchor.constraint(equalToConstant: 52),

            // 検索バーの配置
            searchBar.topAnchor.constraint(equalTo: searchBarContainer.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: searchBarContainer.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: searchBarContainer.trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: searchBarContainer.bottomAnchor)
        ])

        // TableViewの上部余白を調整（検索バーの下から開始するように）
        tableView.contentInset = UIEdgeInsets(top: 52, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }

    private func createStatisticsHeaderView() -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground

        // 検索バー
        headerView.addSubview(searchBar)

        // アコーディオンボタン + 統計コンテナ
        let statsContainer = UIView()
        statsContainer.translatesAutoresizingMaskIntoConstraints = false
        statsContainer.backgroundColor = .secondarySystemGroupedBackground
        statsContainer.layer.cornerRadius = 8

        // アコーディオンボタン
        let accordionButton = UIButton(type: .system)
        accordionButton.translatesAutoresizingMaskIntoConstraints = false
        let chevron = isStatisticsExpanded ? "chevron.down" : "chevron.right"
        accordionButton.setImage(UIImage(systemName: chevron), for: .normal)
        accordionButton.setTitle(" 統計", for: .normal)
        accordionButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        accordionButton.contentHorizontalAlignment = .left
        accordionButton.addTarget(self, action: #selector(toggleStatistics), for: .touchUpInside)
        accordionButton.tag = 999  // タグを設定して後で識別できるように

        statsContainer.addSubview(accordionButton)

        // 統計コンテンツ
        let statsContentStack = UIStackView()
        statsContentStack.axis = .vertical
        statsContentStack.spacing = 4
        statsContentStack.translatesAutoresizingMaskIntoConstraints = false
        statsContentStack.tag = 998  // タグを設定

        let assessments = loadSortedTimerAssessments()

        if !assessments.isEmpty {
            let times = assessments.map { $0.resultTimer }
            let average = times.reduce(0, +) / Double(times.count)
            let fastest = times.min() ?? 0
            let slowest = times.max() ?? 0

            // 1行目: 平均 | 記録数
            let topRow = createStatRow(
                left: ("平均", resultTimerStringFormatter(resultTimer: average)),
                right: ("記録数", "\(assessments.count)件")
            )

            // 2行目: 最速 | 最遅
            let bottomRow = createStatRow(
                left: ("最速", resultTimerStringFormatter(resultTimer: fastest)),
                right: ("最遅", resultTimerStringFormatter(resultTimer: slowest))
            )

            statsContentStack.addArrangedSubview(topRow)
            statsContentStack.addArrangedSubview(bottomRow)
        } else {
            let topRow = createStatRow(
                left: ("平均", "--"),
                right: ("記録数", "0件")
            )
            let bottomRow = createStatRow(
                left: ("最速", "--"),
                right: ("最遅", "--")
            )
            statsContentStack.addArrangedSubview(topRow)
            statsContentStack.addArrangedSubview(bottomRow)
        }

        statsContainer.addSubview(statsContentStack)

        headerView.addSubview(statsContainer)

        // 検索バーの制約（常に表示）
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: headerView.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        ])

        // 統計コンテナの制約
        if isSearching {
            // 検索中は統計コンテナを非表示
            statsContainer.isHidden = true

            NSLayoutConstraint.activate([
                searchBar.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
            ])
        } else {
            statsContainer.isHidden = false

            NSLayoutConstraint.activate([
                statsContainer.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
                statsContainer.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                statsContainer.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                statsContainer.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
            ])

            if isStatisticsExpanded {
                // 展開時: コンテンツを表示
                statsContentStack.isHidden = false

                NSLayoutConstraint.activate([
                    accordionButton.topAnchor.constraint(equalTo: statsContainer.topAnchor, constant: 6),
                    accordionButton.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor, constant: 12),
                    accordionButton.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor, constant: -12),
                    accordionButton.heightAnchor.constraint(equalToConstant: 30),

                    statsContentStack.topAnchor.constraint(equalTo: accordionButton.bottomAnchor, constant: 6),
                    statsContentStack.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor, constant: 12),
                    statsContentStack.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor, constant: -12),
                    statsContentStack.bottomAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: -6)
                ])
            } else {
                // 閉じた時: コンテンツを非表示
                statsContentStack.isHidden = true

                NSLayoutConstraint.activate([
                    accordionButton.topAnchor.constraint(equalTo: statsContainer.topAnchor, constant: 4),
                    accordionButton.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor, constant: 12),
                    accordionButton.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor, constant: -12),
                    accordionButton.bottomAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: -4),
                    accordionButton.heightAnchor.constraint(equalToConstant: 30)
                ])
            }
        }

        return headerView
    }

    private func createStatRow(left: (String, String), right: (String, String)) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 8

        let leftItem = createStatItem(title: left.0, value: left.1)
        let rightItem = createStatItem(title: right.0, value: right.1)

        row.addArrangedSubview(leftItem)
        row.addArrangedSubview(rightItem)

        return row
    }

    private func createStatItem(title: String, value: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 6

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.text = title

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        valueLabel.text = value
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.8

        container.addSubview(label)
        container.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),

            valueLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),

            container.heightAnchor.constraint(equalToConstant: 28)
        ])

        return container
    }

    @objc private func toggleStatistics() {
        isStatisticsExpanded.toggle()
        tableView.reloadData()

        // フィードバック
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
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

        var assessments: [TimerAssessment]

        switch sortType {
        case .dateAscending:
            assessments = timerAssessmentRepository.loadTimerAssessment(
                assessmentItem: assessmentItem,
                sortBy: "createdAt",
                ascending: true
            )
        case .dateDescending:
            assessments = timerAssessmentRepository.loadTimerAssessment(
                assessmentItem: assessmentItem,
                sortBy: "createdAt",
                ascending: false
            )
        case .timeAscending:
            assessments = timerAssessmentRepository.loadTimerAssessment(
                assessmentItem: assessmentItem,
                sortBy: "resultTimer",
                ascending: true
            )
        case .timeDescending:
            assessments = timerAssessmentRepository.loadTimerAssessment(
                assessmentItem: assessmentItem,
                sortBy: "resultTimer",
                ascending: false
            )
        }

        // 検索フィルタリング
        if isSearching {
            assessments = assessments.filter { assessment in
                guard let memo = assessment.memo else { return false }
                return memo.localizedCaseInsensitiveContains(searchText)
            }
        }

        return assessments
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
        // 検索中は統計を非表示
        if isSearching {
            return 52  // 検索バーのみ
        }

        // 検索バー: 52pt
        // 統計ボタン: 30pt (高さ制約)
        // 統計コンテンツ（展開時）: 28 * 2 + 4 = 60pt
        // 余白の計算:
        // - 展開時: 4(上) + 6(ボタン上) + 6(ボタン下) + 6(コンテンツ下) + 8(下) = 30pt
        // - 閉じる時: 4(上) + 4(ボタン上下) + 4(ボタン上下) + 8(下) = 20pt

        if isStatisticsExpanded {
            return 52 + 30 + 60 + 30  // = 172pt (展開時)
        } else {
            return 52 + 30 + 20  // = 102pt（閉じた時）- より小さく
        }
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

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchText = ""
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
}
