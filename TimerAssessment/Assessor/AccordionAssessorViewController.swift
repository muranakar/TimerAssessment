//
//  AccordionAssessorViewController.swift
//  TimerAssessment
//
//  Created by Claude on 2025/10/08.
//

import UIKit
import StoreKit

final class AccordionAssessorViewController: UIViewController {

    private let timerAssessmentRepository = TimerAssessmentRepository()

    // 展開状態を管理
    private var expandedAssessors: Set<UUID> = []
    private var expandedTargetPersons: Set<UUID> = []

    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = Colors.mainColor
        button.tintColor = .white
        button.layer.cornerRadius = 40
        button.layer.shadowOpacity = 0.7
        button.layer.shadowRadius = 3
        button.layer.shadowColor = Colors.mainColor.cgColor
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "評価者"
        setupUI()
        configueViewColor()
        addSettingsButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            addButton.widthAnchor.constraint(equalToConstant: 80),
            addButton.heightAnchor.constraint(equalToConstant: 80)
        ])

        addButton.addTarget(self, action: #selector(addAssessor), for: .touchUpInside)
    }

    // MARK: - Settings
    private func addSettingsButton() {
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(openSettings))
        navigationItem.rightBarButtonItem = settingsButton
    }

    @objc private func openSettings() {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let settingsVC = storyboard.instantiateInitialViewController()!
        settingsVC.modalPresentationStyle = .fullScreen
        present(settingsVC, animated: true)
    }

    // MARK: - Actions
    @objc private func addAssessor() {
        showInputAlert(mode: .input, editingAssessor: nil)
    }

    private func showInputAlert(mode: InputMode, editingAssessor: Assessor?) {
        let title = mode == .input ? "評価者を追加" : "評価者を編集"
        let message = "評価者の名前を入力してください"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "評価者名"
            textField.text = mode == .edit ? editingAssessor?.name : ""
        }

        let saveAction = UIAlertAction(title: "保存", style: .default) { [weak self, weak alert] _ in
            guard let self = self,
                  let textField = alert?.textFields?.first,
                  let name = textField.text, !name.isEmpty else { return }

            switch mode {
            case .input:
                let newAssessor = Assessor(name: name)
                self.timerAssessmentRepository.apppendAssessor(assesor: newAssessor)
            case .edit:
                guard let editingAssessor = editingAssessor else { return }
                let updatedAssessor = Assessor(uuidString: editingAssessor.uuidString, name: name)
                self.timerAssessmentRepository.updateAssessor(assessor: updatedAssessor)
            }

            self.tableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    enum InputMode {
        case input
        case edit
    }

    // MARK: - View Configue
    private func configueViewColor() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "navigation")!
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AccordionAssessorViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        let assessors = timerAssessmentRepository.loadAssessor()
        return assessors.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let assessors = timerAssessmentRepository.loadAssessor()
        guard section < assessors.count else { return 0 }

        let assessor = assessors[section]
        let isExpanded = expandedAssessors.contains(assessor.uuid)

        if !isExpanded {
            return 0
        }

        let targetPersons = timerAssessmentRepository.loadTargetPerson(assessor: assessor)
        var count = targetPersons.count

        // 各対象者の評価項目をカウント
        for targetPerson in targetPersons {
            if expandedTargetPersons.contains(targetPerson.uuid) {
                let assessmentItems = timerAssessmentRepository.loadAssessmentItem(targetPerson: targetPerson)
                count += assessmentItems.count
            }
        }

        return count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let assessors = timerAssessmentRepository.loadAssessor()
        guard section < assessors.count else { return nil }

        let assessor = assessors[section]
        let isExpanded = expandedAssessors.contains(assessor.uuid)

        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "navigation") ?? .systemBlue

        let label = UILabel()
        label.text = "📋 \(assessor.name)"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false

        let arrowLabel = UILabel()
        arrowLabel.text = isExpanded ? "▼" : "▶"
        arrowLabel.font = .systemFont(ofSize: 14)
        arrowLabel.textColor = .white
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false

        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addButton.tintColor = .white
        addButton.tag = section
        addButton.addTarget(self, action: #selector(addTargetPerson(_:)), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false

        let editButton = UIButton(type: .system)
        editButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        editButton.tintColor = .white
        editButton.tag = section
        editButton.addTarget(self, action: #selector(editAssessor(_:)), for: .touchUpInside)
        editButton.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(arrowLabel)
        headerView.addSubview(label)
        headerView.addSubview(addButton)
        headerView.addSubview(editButton)

        NSLayoutConstraint.activate([
            arrowLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            arrowLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            label.leadingAnchor.constraint(equalTo: arrowLabel.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            editButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            editButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 44),
            editButton.heightAnchor.constraint(equalToConstant: 44),

            addButton.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -8),
            addButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 44),
            addButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        headerView.tag = section
        headerView.addGestureRecognizer(tapGesture)

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .default

        let assessors = timerAssessmentRepository.loadAssessor()
        guard indexPath.section < assessors.count else { return cell }

        let assessor = assessors[indexPath.section]
        let targetPersons = timerAssessmentRepository.loadTargetPerson(assessor: assessor)

        var currentRow = 0

        // 対象者レベル
        for (tpIndex, targetPerson) in targetPersons.enumerated() {
            if currentRow == indexPath.row {
                let isExpanded = expandedTargetPersons.contains(targetPerson.uuid)
                cell.textLabel?.text = (isExpanded ? "▼ " : "▶ ") + "👤 \(targetPerson.name)"
                cell.textLabel?.font = .boldSystemFont(ofSize: 16)
                cell.backgroundColor = UIColor.systemGray5
                cell.indentationLevel = 1
                cell.accessoryType = .detailButton
                cell.tag = tpIndex
                return cell
            }
            currentRow += 1

            // 評価項目レベル
            if expandedTargetPersons.contains(targetPerson.uuid) {
                let assessmentItems = timerAssessmentRepository.loadAssessmentItem(targetPerson: targetPerson)
                for (aiIndex, assessmentItem) in assessmentItems.enumerated() {
                    if currentRow == indexPath.row {
                        cell.textLabel?.text = "⏱ \(assessmentItem.name)"
                        cell.textLabel?.font = .systemFont(ofSize: 15)
                        cell.backgroundColor = .systemBackground
                        cell.indentationLevel = 2
                        cell.accessoryType = .disclosureIndicator
                        cell.tag = aiIndex
                        return cell
                    }
                    currentRow += 1
                }
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let assessors = timerAssessmentRepository.loadAssessor()
        guard indexPath.section < assessors.count else { return }

        let assessor = assessors[indexPath.section]
        let targetPersons = timerAssessmentRepository.loadTargetPerson(assessor: assessor)

        var currentRow = 0

        // 対象者タップ
        for targetPerson in targetPersons {
            if currentRow == indexPath.row {
                if expandedTargetPersons.contains(targetPerson.uuid) {
                    expandedTargetPersons.remove(targetPerson.uuid)
                } else {
                    expandedTargetPersons.insert(targetPerson.uuid)
                }
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                return
            }
            currentRow += 1

            // 評価項目タップ
            if expandedTargetPersons.contains(targetPerson.uuid) {
                let assessmentItems = timerAssessmentRepository.loadAssessmentItem(targetPerson: targetPerson)
                for assessmentItem in assessmentItems {
                    if currentRow == indexPath.row {
                        // 機能選択画面へ遷移
                        let nextVC = FunctionSelectionViewController()
                        nextVC.assessmentItem = assessmentItem
                        navigationController?.pushViewController(nextVC, animated: true)
                        return
                    }
                    currentRow += 1
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // 対象者の編集ボタンがタップされた
        let assessors = timerAssessmentRepository.loadAssessor()
        guard indexPath.section < assessors.count else { return }

        let assessor = assessors[indexPath.section]
        let targetPersons = timerAssessmentRepository.loadTargetPerson(assessor: assessor)

        if indexPath.row < targetPersons.count {
            let targetPerson = targetPersons[indexPath.row]
            showTargetPersonAlert(mode: .edit, assessor: assessor, editingTargetPerson: targetPerson)
        }
    }

    @objc private func headerTapped(_ gesture: UITapGestureRecognizer) {
        guard let section = gesture.view?.tag else { return }

        let assessors = timerAssessmentRepository.loadAssessor()
        guard section < assessors.count else { return }

        let assessor = assessors[section]
        if expandedAssessors.contains(assessor.uuid) {
            expandedAssessors.remove(assessor.uuid)
            expandedTargetPersons.removeAll() // 閉じる時は全ての対象者も閉じる
        } else {
            expandedAssessors.insert(assessor.uuid)
        }

        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }

    @objc private func editAssessor(_ sender: UIButton) {
        let section = sender.tag
        let assessors = timerAssessmentRepository.loadAssessor()
        guard section < assessors.count else { return }

        let assessor = assessors[section]
        showInputAlert(mode: .edit, editingAssessor: assessor)
    }

    private func showTargetPersonAlert(mode: TargetPersonInputMode, assessor: Assessor, editingTargetPerson: TargetPerson?) {
        let title = mode == .input ? "対象者を追加" : "対象者を編集"
        let message = "対象者の名前を入力してください"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "対象者名"
            textField.text = mode == .edit ? editingTargetPerson?.name : ""
        }

        let saveAction = UIAlertAction(title: "保存", style: .default) { [weak self, weak alert] _ in
            guard let self = self,
                  let textField = alert?.textFields?.first,
                  let name = textField.text, !name.isEmpty else { return }

            switch mode {
            case .input:
                let newTargetPerson = TargetPerson(name: name)
                self.timerAssessmentRepository.appendTargetPerson(assessor: assessor, targetPerson: newTargetPerson)
            case .edit:
                guard let editingTargetPerson = editingTargetPerson else { return }
                let updatedTargetPerson = TargetPerson(uuidString: editingTargetPerson.uuidString, name: name)
                self.timerAssessmentRepository.updateTargetPerson(targetPerson: updatedTargetPerson)
            }

            self.tableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    enum TargetPersonInputMode {
        case input
        case edit
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let assessors = timerAssessmentRepository.loadAssessor()
        guard indexPath.section < assessors.count else { return }

        let assessor = assessors[indexPath.section]
        let targetPersons = timerAssessmentRepository.loadTargetPerson(assessor: assessor)

        var currentRow = 0

        // 対象者削除
        for targetPerson in targetPersons {
            if currentRow == indexPath.row {
                timerAssessmentRepository.removeTargetPerson(targetPerson: targetPerson)
                tableView.reloadData()
                return
            }
            currentRow += 1

            // 評価項目削除
            if expandedTargetPersons.contains(targetPerson.uuid) {
                let assessmentItems = timerAssessmentRepository.loadAssessmentItem(targetPerson: targetPerson)
                for assessmentItem in assessmentItems {
                    if currentRow == indexPath.row {
                        timerAssessmentRepository.removeAssessmentItem(assessmentItem: assessmentItem)
                        tableView.reloadData()
                        return
                    }
                    currentRow += 1
                }
            }
        }
    }
}
