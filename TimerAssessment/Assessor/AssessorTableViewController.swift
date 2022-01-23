//
//  AssessorTableViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

class AssessorTableViewController: UITableViewController {
    var selectedAssessorUUID: UUID?
    var editingAssessorUUID: UUID?
    let fimRepository = FIMRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        configueColor()
    }

    // MARK: - Segue-　AssessorTableViewController →　inputAccessoryViewController
    @IBAction private func input(_ sender: Any) {
        performSegue(withIdentifier: "input", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController else { return }
        if let inputVC = nav.topViewController as? InputAssessorViewController {
            switch segue.identifier ?? "" {
            case "input":
                inputVC.mode = .input
            case "edit":
                guard let editingAssessorUUID = editingAssessorUUID else {
                    return
                }
                inputVC.mode = .edit(editingAssessorUUID)
            default:
                break
            }
        }
        if let nextVC = nav.topViewController as? TargetPersonTableViewController {
            switch segue.identifier ?? "" {
            case "next":
                nextVC.assessorUUID = selectedAssessorUUID
            default:
                break
            }
        }
    }

    // MARK: - Segue- AssessorTableViewController ←　inputAccessoryViewController
    @IBAction private func backToAssessorTableViewController(segue: UIStoryboardSegue) { }

    @IBAction private func save(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fimRepository.loadAssessor().count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AssessorTableViewCell
        let assessor = fimRepository.loadAssessor()[indexPath.row]
        cell.configue(assessor: assessor)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAssessorUUID = fimRepository.loadAssessor()[indexPath.row].uuid
        performSegue(withIdentifier: "next", sender: nil)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editingAssessorUUID = fimRepository.loadAssessor()[indexPath.row].uuid
        performSegue(withIdentifier: "edit", sender: nil)
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let uuid = fimRepository.loadAssessor()[indexPath.row].uuid else { return }
        fimRepository.removeAssessor(uuid: uuid)
        tableView.reloadData()
    }
    // MARK: - View Configue
    private func configueColor() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.baseColor
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
}
