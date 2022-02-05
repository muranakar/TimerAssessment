//
//  FunctionSelectionViewController.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/01.
//

import UIKit

final class FunctionSelectionViewController: UIViewController {
    // 変数の受け皿
    var assessmentItem: AssessmentItem?
    let timerAssessmetRepository = TimerAssessmentRepository()
    @IBOutlet weak private var asssessmentButton: UIButton!
    @IBOutlet weak private var assessmentListButton: UIButton!
    @IBOutlet weak private var assessmentItemLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let targetPersonName = timerAssessmetRepository.loadTargetPerson(assessmentItem: assessmentItem!)?.name ?? ""
        let assessmentItemName = assessmentItem?.name ?? ""

        navigationItem.title = "対象者:\(targetPersonName)様"
        assessmentItemLabel.text = assessmentItemName
        configueViewNavigationBarColor()
        configueViewButtonStyle()
    }

    @IBAction private func toAssessmentVC(_ sender: Any) {
        toAssessmentViewController(assessmentItem: assessmentItem!)
    }

    @IBAction private func toFIMTableVC(_ sender: Any) {
        toPastAssessmentViewController(assessmentItem: assessmentItem!)
    }

    // MARK: - Segue- FunctionSelectionViewController ← AssessmentViewController
    @IBAction private func backToFunctionSelectionTableViewController(segue: UIStoryboardSegue) {
    }
    // MARK: - Method
    private func toAssessmentViewController(assessmentItem: AssessmentItem) {
        let storyboard = UIStoryboard(name: "Assessment", bundle: nil)
        let nextVC =  storyboard.instantiateViewController(withIdentifier: "assessment") as! AssessmentViewController
        nextVC.assessmentItem = assessmentItem
        navigationController?.pushViewController(nextVC, animated: true)
    }

    private func toPastAssessmentViewController(assessmentItem: AssessmentItem) {
        let storyboard = UIStoryboard(name: "PastAssessment", bundle: nil)
        let nextVC =
        storyboard.instantiateViewController(withIdentifier: "pastAssessment") as! PastAssessmentViewController
        nextVC.assessmentItem = assessmentItem
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
        assessmentListButton.tintColor = Colors.baseColor
        assessmentListButton.backgroundColor = Colors.mainColor
        assessmentListButton.layer.cornerRadius = 10
        assessmentListButton.layer.shadowOpacity = 0.7
        assessmentListButton.layer.shadowRadius = 3
        assessmentListButton.layer.shadowColor = UIColor.black.cgColor
        assessmentListButton.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
}
