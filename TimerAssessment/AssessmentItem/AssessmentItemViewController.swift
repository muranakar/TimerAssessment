//
//  AssessmentItemViewController.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/01/31.
//

import UIKit

class AssessmentItemViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource {
    var targetPerson: TargetPerson?
    private var selectedAssessmentItem: AssessmentItem?
    private var editingAssessmentItem: AssessmentItem?
    private let timerAssessmentRepository = TimerAssessmentRepository()
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var inputButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        guard let targetPersonName = timerAssessmentRepository.loadTargetPerson(targetPersonUUID: (targetPerson?.uuid)!)?.name else {
            return
        }
        navigationItem.title = "\(targetPersonName)　様の評価項目リスト"
        configueViewColor()
        configueViewButton()
    }
    // MARK: - Segue- TargetPersonViewController →　InputTargetPersonViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController else { return }
        if let inputVC = nav.topViewController as? InputAssessmentItemViewController {
            switch segue.identifier ?? "" {
            case "input":
                inputVC.mode = .input
                inputVC.targetPerson = targetPerson
            case "edit":
                inputVC.mode = .edit
                inputVC.editingAssessmentItem = editingAssessmentItem
            default:
                break
            }
        }
    }

    @IBAction private func input(_ sender: Any) {
        performSegue(withIdentifier: "input", sender: nil)
    }

    // MARK: - Segue- TargetPersonViewController ←　InputTargetPersonViewController
    @IBAction private func backToAssessmentItemTableViewController(segue: UIStoryboardSegue) { }

    @IBAction private func save(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    // MARK: -ここまで完了
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        timerAssessmentRepository.loadTargetPerson(assessorUUID: assessorUUID!).count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TargetPersonTableViewCell
        let targetPerson = timerAssessmentRepository.loadTargetPerson(assessorUUID: assessorUUID!)[indexPath.row]
        cell.configue(name: targetPerson.name)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTargetPersonUUID = timerAssessmentRepository.loadTargetPerson(
            assessorUUID: assessorUUID!
        )[indexPath.row].uuid
        toFunctionSelectionViewController(selectedTargetPersonUUID: selectedTargetPersonUUID)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editingTargetPersonUUID = timerAssessmentRepository.loadTargetPerson(
            assessorUUID: assessorUUID!
        )[indexPath.row].uuid
        performSegue(withIdentifier: "edit", sender: nil)
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }
        let targetPerson = timerAssessmentRepository.loadTargetPerson(assessorUUID: assessorUUID!)[indexPath.row]
        timerAssessmentRepository.removeTargetPerson(targetPerson: targetPerson)
        tableView.reloadData()
    }
    // MARK: - Method
    private func toFunctionSelectionViewController(selectedTargetPersonUUID: UUID?) {
//        let storyboard = UIStoryboard(name: "FunctionSelection", bundle: nil)
//        let nextVC =
//        storyboard.instantiateViewController(withIdentifier: "functionSelection") as! FunctionSelectionViewController
//        nextVC.targetPersonUUID = selectedTargetPersonUUID
//        navigationController?.pushViewController(nextVC, animated: true)
    }
    // MARK: - View Configue
    private func configueViewColor() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.baseColor
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