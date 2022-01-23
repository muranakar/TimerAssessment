//
//  AssessorViewController.swift
//  FunctionalIndependenceMeasure
//
//  Created by 村中令 on 2022/01/11.
//

import UIKit

final class AssessorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak private var tableview: UITableView!
    @IBOutlet weak private var inputButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        configueViewColor()
        configueViewButton()
    }
    var selectedAssessorUUID: UUID?
    var editingAssessorUUID: UUID?
    let fimRepository = FIMRepository()

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
                inputVC.editingAssessorUUID = editingAssessorUUID
                inputVC.mode = .edit
            default:
                break
            }
        }
    }

    // MARK: - Segue- AssessorTableViewController ←　inputAccessoryViewController
    @IBAction private func backToAssessorTableViewController(segue: UIStoryboardSegue) { }

    @IBAction private func save(segue: UIStoryboardSegue) {
        tableview.reloadData()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fimRepository.loadAssessor().count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AssessorTableViewCell
        let assessor = fimRepository.loadAssessor()[indexPath.row]
        cell.configue(assessor: assessor)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAssessorUUID = fimRepository.loadAssessor()[indexPath.row].uuid
        toTargetPersonViewController(selectedAssessorUUID: selectedAssessorUUID)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editingAssessorUUID = fimRepository.loadAssessor()[indexPath.row].uuid
        performSegue(withIdentifier: "edit", sender: nil)
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let uuid = fimRepository.loadAssessor()[indexPath.row].uuid else { return }
        fimRepository.removeAssessor(uuid: uuid)
        tableView.reloadData()
    }
    // MARK: - Method
    private func toTargetPersonViewController(selectedAssessorUUID: UUID?) {
        let storyboard = UIStoryboard(name: "TargetPerson", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "targetPerson") as! TargetPersonViewController
        nextVC.assessorUUID = selectedAssessorUUID
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
