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
    private var editingAssessmentItem: AssessmentItem?
    private let timerAssessmentRepository = TimerAssessmentRepository()
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var inputButton: UIButton!
    @IBOutlet weak private var twitterButton: UIButton!

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
        configueViewButtonTwitterURL()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.selectRow(at: nil, animated: animated, scrollPosition: .none)
    }
    // MARK: - Twitterへの遷移ボタン
    @IBAction private func moveTwitterURL(_ sender: Any) {
        let url = NSURL(string: "https://twitter.com/KaradaHelp")
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
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
        editingAssessmentItem = timerAssessmentRepository.loadAssessmentItem(targetPerson: targetPerson!)[indexPath.row]
        performSegue(withIdentifier: "edit", sender: nil)
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
