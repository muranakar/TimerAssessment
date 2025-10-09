//
//  FunctionSelectionViewController.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/01.
//

import UIKit
import StoreKit

final class FunctionSelectionViewController: UIViewController {
    // 変数の受け皿
    var assessmentItem: AssessmentItem?
    let timerAssessmetRepository = TimerAssessmentRepository()

    // UI Components
    private let assessmentItemTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "評価項目"
        label.font = .boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let assessmentItemLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let assessmentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("評価開始", for: .normal)
        button.setImage(UIImage(systemName: "applepencil"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let assessmentListButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("過去評価一覧", for: .normal)
        button.setImage(UIImage(systemName: "list.dash"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadData()
        addSettingsButton()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(assessmentItemTitleLabel)
        view.addSubview(assessmentItemLabel)
        view.addSubview(assessmentButton)
        view.addSubview(assessmentListButton)

        NSLayoutConstraint.activate([
            // Title Label
            assessmentItemTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            assessmentItemTitleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -200),

            // Assessment Item Label
            assessmentItemLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            assessmentItemLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            assessmentItemLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            assessmentItemLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150),

            // Assessment Button
            assessmentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            assessmentButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            assessmentButton.widthAnchor.constraint(equalToConstant: 200),
            assessmentButton.heightAnchor.constraint(equalToConstant: 70),

            // Assessment List Button
            assessmentListButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            assessmentListButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 90),
            assessmentListButton.widthAnchor.constraint(equalToConstant: 200),
            assessmentListButton.heightAnchor.constraint(equalToConstant: 70)
        ])

        assessmentButton.addTarget(self, action: #selector(toAssessmentVC), for: .touchUpInside)
        assessmentListButton.addTarget(self, action: #selector(toFIMTableVC), for: .touchUpInside)

        configueViewButtonStyle()
    }

    private func setupNavigationBar() {
        configueViewNavigationBarColor()
    }

    private func loadData() {
        let targetPersonName = timerAssessmetRepository.loadTargetPerson(assessmentItem: assessmentItem!)?.name ?? ""
        let assessmentItemName = assessmentItem?.name ?? ""
        navigationItem.title = "対象者:\(targetPersonName)様"
        assessmentItemLabel.text = assessmentItemName
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

    @objc private func toAssessmentVC() {
        toAssessmentViewController(assessmentItem: assessmentItem!)
    }

    @objc private func toFIMTableVC() {
        toPastAssessmentViewController(assessmentItem: assessmentItem!)
    }

    // MARK: - Method
    private func toAssessmentViewController(assessmentItem: AssessmentItem) {
        let nextVC = AssessmentViewController()
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
        appearance.backgroundColor = UIColor(named: "navigation")!
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }

    private func configueViewButtonStyle() {
        [assessmentButton, assessmentListButton].forEach { button in
            button.tintColor = Colors.baseColor
            button.backgroundColor = Colors.mainColor
            button.layer.cornerRadius = 10
            button.layer.shadowOpacity = 0.7
            button.layer.shadowRadius = 3
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 1, height: 1)
        }
    }
}
