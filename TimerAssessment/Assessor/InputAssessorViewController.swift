//
//  InputAssessorViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

final class InputAssessorViewController: UIViewController {
    // 画面遷移元から、値を代入される変数
    var editingAssessorUUID: UUID?

    enum Mode {
        case input
        case edit
    }
    var mode: Mode?
    let timerAssessmentRepository = TimerAssessmentRepository()

    var assessor: Assessor?
    @IBOutlet weak private var assessorNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mode = mode else { fatalError("mode の中身が入っていない") }
        assessorNameTextField.text = getName(mode: mode)
        configueColor()
    }
    // MARK: - Method
    private func getName(mode: Mode) -> String? {
        switch mode {
        case .input:
            return ""
        case .edit:
            guard let editingAssessorUUID = editingAssessorUUID else {
                fatalError("editingAssessorUUID の中身が入っていない")
            }
            let assesorName =
            timerAssessmentRepository.loadAssessor(assessorUUID: editingAssessorUUID)?.name
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
            guard let editingAssessorUUID = editingAssessorUUID else {
                return
            }
            let editAssessorName = assessorNameTextField.text ?? ""
            timerAssessmentRepository.updateAssessor(
                assessor: Assessor(
                    uuidString: editingAssessorUUID.uuidString,
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
}
