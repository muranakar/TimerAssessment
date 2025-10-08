//
//  TargetPersonViewController.swift
//  FunctionalIndependenceMeasure
//
//  Created by 村中令 on 2022/01/11.
//

import UIKit

final class TargetPersonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var assessor: Assessor?
    private var selectedTargetPerson: TargetPerson?
    private let timerAssessmentRepository = TimerAssessmentRepository()
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var inputButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        guard let assessorName = timerAssessmentRepository.loadAssessor(assessor: assessor!)?.name else {
            return
        }
        navigationItem.title = "\(assessorName)　様の対象者リスト"
        configueViewColor()
        configueViewButton()
        addSettingsButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.selectRow(at: nil, animated: animated, scrollPosition: .none)
    }
    // MARK: - Unwind Segue
    @IBAction func backToTargetPersonTableViewController(segue: UIStoryboardSegue) {
        tableView.reloadData()
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
    // MARK: - 対象者追加アラート
    @IBAction private func input(_ sender: Any) {
        showInputAlert(mode: .input, editingTargetPerson: nil)
    }

    private func showInputAlert(mode: InputMode, editingTargetPerson: TargetPerson?) {
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
                  let name = textField.text, !name.isEmpty,
                  let assessor = self.assessor else { return }

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

    enum InputMode {
        case input
        case edit
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        timerAssessmentRepository.loadTargetPerson(assessor: assessor!).count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TargetPersonTableViewCell
        let targetPerson = timerAssessmentRepository.loadTargetPerson(assessor: assessor!)[indexPath.row]
        cell.configue(name: targetPerson.name)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTargetPerson = timerAssessmentRepository.loadTargetPerson(
            assessor: assessor!
        )[indexPath.row]
        toFunctionSelectionViewController(selectedTargetPerson: selectedTargetPerson)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let targetPerson = timerAssessmentRepository.loadTargetPerson(assessor: assessor!)[indexPath.row]
        showInputAlert(mode: .edit, editingTargetPerson: targetPerson)
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }
        let targetPerson = timerAssessmentRepository.loadTargetPerson(assessor: assessor!)[indexPath.row]
        timerAssessmentRepository.removeTargetPerson(targetPerson: targetPerson)
        tableView.reloadData()
    }
    // MARK: - Method
    private func toFunctionSelectionViewController(selectedTargetPerson: TargetPerson?) {
        let storyboard = UIStoryboard(name: "AssessmentItem", bundle: nil)
        let nextVC = storyboard.instantiateViewController(
            withIdentifier: "assessmentItem"
        ) as! AssessmentItemViewController
        nextVC.targetPerson = timerAssessmentRepository.loadTargetPerson(targetPerson: selectedTargetPerson!)
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
