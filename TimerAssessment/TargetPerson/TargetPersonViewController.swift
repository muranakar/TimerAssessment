//
//  TargetPersonViewController.swift
//  FunctionalIndependenceMeasure
//
//  Created by 村中令 on 2022/01/11.
//

import UIKit

final class TargetPersonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var assessorUUID: UUID?
    private var selectedTargetPersonUUID: UUID?
    private var editingTargetPersonUUID: UUID?
    private let fimRepository = FIMRepository()
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var inputButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        guard let assessorName = fimRepository.loadAssessor(assessorUUID: assessorUUID!)?.name else {
            return
        }
        navigationItem.title = "\(assessorName)　様の対象者リスト"
        configueViewColor()
        configueViewButton()
    }
    // MARK: - Segue- TargetPersonViewController →　InputTargetPersonViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController else { return }
        if let inputVC = nav.topViewController as? InputTargetPersonViewController {
            switch segue.identifier ?? "" {
            case "input":
                inputVC.mode = .input
                inputVC.assessorUUID = assessorUUID
            case "edit":
                guard let editingTargetPersonUUID = editingTargetPersonUUID else {
                    return
                }
                inputVC.mode = .edit
                inputVC.editingTargetPersonUUID = editingTargetPersonUUID
            default:
                break
            }
        }
    }

    @IBAction private func input(_ sender: Any) {
        performSegue(withIdentifier: "input", sender: nil)
    }

    // MARK: - Segue- TargetPersonViewController ←　InputTargetPersonViewController
    @IBAction private func backToTargetPersonTableViewController(segue: UIStoryboardSegue) { }

    @IBAction private func save(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fimRepository.loadTargetPerson(assessorUUID: assessorUUID!).count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TargetPersonTableViewCell
        let tagetPerson = fimRepository.loadTargetPerson(assessorUUID: assessorUUID!)[indexPath.row]
        cell.configue(name: tagetPerson.name)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTargetPersonUUID = fimRepository.loadTargetPerson(assessorUUID: assessorUUID!)[indexPath.row].uuid
        toFunctionSelectionViewController(selectedTargetPersonUUID: selectedTargetPersonUUID)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editingTargetPersonUUID = fimRepository.loadTargetPerson(assessorUUID: assessorUUID!)[indexPath.row].uuid
        performSegue(withIdentifier: "edit", sender: nil)
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }
        guard let uuid = fimRepository.loadTargetPerson(assessorUUID: assessorUUID!)[indexPath.row].uuid else { return }
        fimRepository.removeTargetPerson(targetPersonUUID: uuid)
        tableView.reloadData()
    }
    // MARK: - Method
    private func toFunctionSelectionViewController(selectedTargetPersonUUID: UUID?) {
        let storyboard = UIStoryboard(name: "FunctionSelection", bundle: nil)
        let nextVC =
        storyboard.instantiateViewController(withIdentifier: "functionSelection") as! FunctionSelectionViewController
        nextVC.targetPersonUUID = selectedTargetPersonUUID
        navigationController?.pushViewController(nextVC, animated: true)
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
