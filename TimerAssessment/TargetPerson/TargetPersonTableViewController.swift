//
//  TargetPersonTableViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

class TargetPersonTableViewController: UITableViewController {
    var assessorUUID: UUID?
    private var selectedTargetPersonUUID: UUID?
    private var editingTargetPersonUUID: UUID?
    private let fimRepository = FIMRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let assessorName = fimRepository.loadAssessor(assessorUUID: assessorUUID!)?.name else {
            return
        }
        navigationItem.title = "\(assessorName)様の対象者リスト"
        configueColor()
    }
    // MARK: - Segue- TargetPersonTableViewController →　InputTargetPersonViewController
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
                inputVC.mode = .edit(editingTargetPersonUUID)
                inputVC.assessorUUID = assessorUUID
            default:
                break
            }
        }
        if let nextVC = nav.topViewController as? FunctionSelectionViewController {
            switch segue.identifier ?? "" {
            case "next":
                nextVC.targetPersonUUID = selectedTargetPersonUUID
            default:
                break
            }
        }
    }

    @IBAction private func input(_ sender: Any) {
        performSegue(withIdentifier: "input", sender: nil)
    }

    // MARK: - Segue- TargetPersonTableViewController ←　InputTargetPersonViewController
    @IBAction private func backToTargetPersonTableViewController(segue: UIStoryboardSegue) { }

    @IBAction private func save(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fimRepository.loadTargetPerson(assessorUUID: assessorUUID!).count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TargetPersonTableViewCell
        let tagetPerson = fimRepository.loadTargetPerson(assessorUUID: assessorUUID!)[indexPath.row]
        cell.configue(name: tagetPerson.name)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTargetPersonUUID = fimRepository.loadTargetPerson(assessorUUID: assessorUUID!)[indexPath.row].uuid
        performSegue(withIdentifier: "next", sender: nil)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editingTargetPersonUUID = fimRepository.loadTargetPerson(assessorUUID: assessorUUID!)[indexPath.row].uuid
        performSegue(withIdentifier: "edit", sender: nil)
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let uuid = fimRepository.loadTargetPerson(assessorUUID: assessorUUID!)[indexPath.row].uuid else { return }
        fimRepository.removeTargetPerson(targetPersonUUID: uuid)
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

    private func configueViewButton() {}
}
