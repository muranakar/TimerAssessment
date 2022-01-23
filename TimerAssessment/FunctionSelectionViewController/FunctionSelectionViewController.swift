//
//  FunctionSelectionViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

final class FunctionSelectionViewController: UIViewController {
    var targetPersonUUID: UUID?
    let fimRepository = FIMRepository()
    @IBOutlet weak private var asssessmentButton: UIButton!
    @IBOutlet weak private var fimListButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let targetPersonName =  fimRepository.loadTargetPerson(targetPersonUUID: targetPersonUUID!)?.name else {
            return
        }
        navigationItem.title = "対象者:　\(targetPersonName)　様"
        configueViewNavigationBarColor()
        configueViewButtonStyle()
    }
    @IBAction private func toAssessmentVC(_ sender: Any) {
        toAssessmentViewController(targetPersonUUID: targetPersonUUID)
    }

    @IBAction private func toFIMTableVC(_ sender: Any) {
        toFIMTableViewController(targetPersonUUID: targetPersonUUID)
    }

    // MARK: - Segue- FunctionSelectionViewController ← AssessmentViewController
    @IBAction private func backToFunctionSelectionTableViewController(segue: UIStoryboardSegue) {
    }
    // MARK: - Method
    private func toAssessmentViewController(targetPersonUUID: UUID?) {
        let storyboard = UIStoryboard(name: "Assessment", bundle: nil)
        let nextVC =
        storyboard.instantiateViewController(withIdentifier: "assessment") as! AssessmentViewController
        nextVC.targetPersonUUID = targetPersonUUID
        navigationController?.pushViewController(nextVC, animated: true)
    }

    private func toFIMTableViewController(targetPersonUUID: UUID?) {
        let storyboard = UIStoryboard(name: "FIMTable", bundle: nil)
        let nextVC =
        storyboard.instantiateViewController(withIdentifier: "fimTable") as! FIMTableViewController
        nextVC.targetPersonUUID = targetPersonUUID
        navigationController?.pushViewController(nextVC, animated: true)
    }

    // MARK: - View Configue
    private func configueViewNavigationBarColor() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.baseColor
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }

    private func configueViewButtonStyle() {
        asssessmentButton.tintColor = Colors.baseColor
        asssessmentButton.backgroundColor = Colors.mainColor
        asssessmentButton.layer.cornerRadius = 10
        asssessmentButton.layer.shadowOpacity = 0.7
        asssessmentButton.layer.shadowRadius = 3
        asssessmentButton.layer.shadowColor = UIColor.black.cgColor
        asssessmentButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        fimListButton.tintColor = Colors.baseColor
        fimListButton.backgroundColor = Colors.mainColor
        fimListButton.layer.cornerRadius = 10
        fimListButton.layer.shadowOpacity = 0.7
        fimListButton.layer.shadowRadius = 3
        fimListButton.layer.shadowColor = UIColor.black.cgColor
        fimListButton.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
}
