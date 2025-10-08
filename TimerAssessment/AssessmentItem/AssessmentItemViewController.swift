//
//  AssessmentItemViewController.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/01/31.
//

import UIKit

final class AssessmentItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // 画面遷移時の変数の受け取り
    var targetPerson: TargetPerson?

    // 画面遷移した際に使用したり、一時的に保存する変数
    private var selectedAssessmentItem: AssessmentItem?
    private let timerAssessmentRepository = TimerAssessmentRepository()

    // プリセット項目
    private let presetItems = ["起立動作", "10m歩行", "片脚立位(右)", "片脚立位(左)", "TUG"]
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var inputButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        guard let targetPersonName = targetPerson?.name else {
            return
        }
        navigationItem.title = "\(targetPersonName)　様の評価項目リスト"
        configueViewColor()
        configueViewButton()
        addSettingsButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.selectRow(at: nil, animated: animated, scrollPosition: .none)
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
    // MARK: - 評価項目追加アクションシート
    @IBAction private func input(_ sender: Any) {
        showInputActionSheet(mode: .input, editingAssessmentItem: nil)
    }

    private func showInputActionSheet(mode: InputMode, editingAssessmentItem: AssessmentItem?) {
        if mode == .edit {
            // 編集モードはアラートで表示
            showEditAlert(editingAssessmentItem: editingAssessmentItem)
            return
        }

        // 追加モードはアクションシートで表示
        let actionSheet = UIAlertController(title: "評価項目を追加", message: "選択してください", preferredStyle: .actionSheet)

        // プリセット項目を追加
        for item in presetItems {
            let action = UIAlertAction(title: item, style: .default) { [weak self] _ in
                guard let self = self, let targetPerson = self.targetPerson else { return }
                let newAssessmentItem = AssessmentItem(name: item)
                self.timerAssessmentRepository.appendAssessmentItem(targetPerson: targetPerson, assessmentItem: newAssessmentItem)
                self.tableView.reloadData()
            }
            actionSheet.addAction(action)
        }

        // カスタム入力
        let customAction = UIAlertAction(title: "カスタム入力", style: .default) { [weak self] _ in
            self?.showCustomInputAlert()
        }
        actionSheet.addAction(customAction)

        // キャンセル
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        actionSheet.addAction(cancelAction)

        present(actionSheet, animated: true)
    }

    private func showCustomInputAlert() {
        let alert = UIAlertController(title: "カスタム項目を追加", message: "評価項目名を入力してください", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "評価項目名"
        }

        let saveAction = UIAlertAction(title: "保存", style: .default) { [weak self, weak alert] _ in
            guard let self = self,
                  let textField = alert?.textFields?.first,
                  let name = textField.text, !name.isEmpty,
                  let targetPerson = self.targetPerson else { return }

            let newAssessmentItem = AssessmentItem(name: name)
            self.timerAssessmentRepository.appendAssessmentItem(targetPerson: targetPerson, assessmentItem: newAssessmentItem)
            self.tableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    private func showEditAlert(editingAssessmentItem: AssessmentItem?) {
        let alert = UIAlertController(title: "評価項目を編集", message: "評価項目名を入力してください", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "評価項目名"
            textField.text = editingAssessmentItem?.name
        }

        let saveAction = UIAlertAction(title: "保存", style: .default) { [weak self, weak alert] _ in
            guard let self = self,
                  let textField = alert?.textFields?.first,
                  let name = textField.text, !name.isEmpty,
                  let editingAssessmentItem = editingAssessmentItem else { return }

            let updatedAssessmentItem = AssessmentItem(uuidString: editingAssessmentItem.uuidString, name: name)
            self.timerAssessmentRepository.updateAssessmentItem(assessmentItem: updatedAssessmentItem)
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

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        timerAssessmentRepository.loadAssessmentItem(targetPerson: targetPerson!).count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AssessmentItemTableViewCell
        let assessmentItem = timerAssessmentRepository.loadAssessmentItem(targetPerson: targetPerson!)[indexPath.row]
        cell.configue(name: assessmentItem.name)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAssessmentItem = timerAssessmentRepository.loadAssessmentItem(
            targetPerson: targetPerson!
        )[indexPath.row]
        toFunctionSelectionViewController(selectedAssessmentItem: selectedAssessmentItem!)
        // MARK: - 次の画面を作成したあとに作成。

        //        selectedTargetPersonUUID = timerAssessmentRepository.loadTargetPerson(
        //            assessorUUID: assessorUUID!
        //        )[indexPath.row].uuid
        //        toFunctionSelectionViewController(selectedTargetPersonUUID: selectedTargetPersonUUID)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let assessmentItem = timerAssessmentRepository.loadAssessmentItem(targetPerson: targetPerson!)[indexPath.row]
        showInputActionSheet(mode: .edit, editingAssessmentItem: assessmentItem)
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }
        let assessmentItem = timerAssessmentRepository.loadAssessmentItem(targetPerson: targetPerson!)[indexPath.row]
        timerAssessmentRepository.removeAssessmentItem(assessmentItem: assessmentItem)
        tableView.reloadData()
    }
    // MARK: - Method
    private func toFunctionSelectionViewController(selectedAssessmentItem: AssessmentItem) {
                let storyboard = UIStoryboard(name: "FunctionSelection", bundle: nil)
                let nextVC =
                storyboard.instantiateViewController(
            withIdentifier: "functionSelection"
                ) as! FunctionSelectionViewController
                nextVC.assessmentItem = selectedAssessmentItem
                navigationController?.pushViewController(nextVC, animated: true)
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

    private func configueViewButton() {
        inputButton.backgroundColor = Colors.mainColor
        inputButton.tintColor = .white
        inputButton.layer.cornerRadius = 40
        inputButton.imageView?.contentMode = .scaleAspectFill
        inputButton.contentVerticalAlignment = .fill
        inputButton.contentHorizontalAlignment = .fill
        inputButton.layer.shadowOpacity = 0.7
        inputButton.layer.shadowRadius = 3
        inputButton.layer.shadowColor = Colors.mainColor.cgColor
        inputButton.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
}
