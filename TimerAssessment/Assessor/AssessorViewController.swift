//
//  AssessorViewController.swift
//  FunctionalIndependenceMeasure
//
//  Created by 村中令 on 2022/01/11.
//

import UIKit
import StoreKit

final class AssessorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak private var tableview: UITableView!
    @IBOutlet weak private var inputButton: UIButton!
    @IBOutlet weak private var twitterButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        configueViewColor()
        configueViewButton()
        configueViewButtonTwitterURL()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableview.selectRow(at: nil, animated: animated, scrollPosition: .none)
    }

    var selectedAssessor: Assessor?
    let timerAssessmentRepository = TimerAssessmentRepository()

    // MARK: - Twitterへの遷移ボタン
    @IBAction private func moveTwitterURL(_ sender: Any) {
        let url = NSURL(string: "https://twitter.com/KaradaHelp")
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    // MARK: - 評価者追加アラート
    @IBAction private func input(_ sender: Any) {
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

            self.tableview.reloadData()
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
        timerAssessmentRepository.loadAssessor().count    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AssessorTableViewCell
        let assessor = timerAssessmentRepository.loadAssessor()[indexPath.row]
        cell.configue(assessor: assessor)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAssessor = timerAssessmentRepository.loadAssessor()[indexPath.row]
        toTargetPersonViewController(selectedAssessor: selectedAssessor)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let assessor = timerAssessmentRepository.loadAssessor()[indexPath.row]
        showInputAlert(mode: .edit, editingAssessor: assessor)
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let assessors = timerAssessmentRepository.loadAssessor()
        let assessor = assessors[indexPath.row]
        timerAssessmentRepository.removeAssessor(assessor: assessor)
        tableView.reloadData()
    }

    // MARK: - Method
    private func toTargetPersonViewController(selectedAssessor: Assessor?) {
        let storyboard = UIStoryboard(name: "TargetPerson", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "targetPerson") as! TargetPersonViewController
        nextVC.assessor = selectedAssessor
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
    private func configueViewButtonTwitterURL() {
        twitterButton.backgroundColor = .white
        twitterButton.layer.cornerRadius = 20
        twitterButton.imageView?.contentMode = .scaleAspectFill
        twitterButton.contentVerticalAlignment = .fill
        twitterButton.contentHorizontalAlignment = .fill
        twitterButton.layer.shadowOpacity = 0.7
        twitterButton.layer.shadowRadius = 5
        twitterButton.layer.shadowColor = Colors.mainColor.cgColor
        twitterButton.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
}
