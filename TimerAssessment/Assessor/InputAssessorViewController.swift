//
//  InputAssessorViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

final class InputAssessorViewController: UIViewController {
    // 画面遷移元から、値を代入される変数
    var editingAssessor: Assessor?

    enum Mode {
        case input
        case edit
    }
    var mode: Mode?
    let timerAssessmentRepository = TimerAssessmentRepository()

    var assessor: Assessor?
    @IBOutlet weak private var assessorView: UIView!
    @IBOutlet weak private var assessorNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mode = mode else { fatalError("mode の中身が入っていない") }
        assessorNameTextField.text = getName(mode: mode)
        configueColor()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configueViewAssessorView()
    }
    // MARK: - Method
    private func getName(mode: Mode) -> String? {
        switch mode {
        case .input:
            return ""
        case .edit:
            guard let editingAssessor = editingAssessor else {
                fatalError("editingAssessor の中身が入っていない")
            }
            let assesorName =
            timerAssessmentRepository.loadAssessor(assessor: editingAssessor)?.name
            return assesorName
        }
    }

// MARK: - 評価者データを保存するUIButtonのIBAction
    @IBAction private func saveAction(_ sender: Any) {
        guard let mode = mode else { return }

        switch mode {
        case .input:
            let newAssessor = Assessor(name: assessorNameTextField.text ?? "")
            timerAssessmentRepository.apppendAssessor(assesor: newAssessor)
        case .edit:
            guard let editingAssessor = editingAssessor else {
                return
            }
            let editAssessorName = assessorNameTextField.text ?? ""
            timerAssessmentRepository.updateAssessor(
                assessor: Assessor(
                    uuidString: editingAssessor.uuidString,
                    name: editAssessorName
                ))
        }
        performSegue(
            withIdentifier: "save",
            sender: sender
        )
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
    private func configueViewAssessorView() {
        assessorView.backgroundColor = .white
        assessorView.layer.cornerRadius = 20
        assessorView.layer.shadowOpacity = 0.7
        assessorView.layer.shadowRadius = 5
        assessorView.layer.shadowColor = Colors.mainColor.cgColor
        assessorView.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
}
