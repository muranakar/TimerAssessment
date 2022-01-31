//
//  InputAssessmentItemViewController.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/01/31.
//

import UIKit

class InputAssessmentItemViewController: UIViewController {
    // 画面遷移時に値を受け取る変数
    var targetPerson: TargetPerson?
    enum Mode {
        case input
        case edit
    }

    var mode: Mode?
    private let timerAssessmentRepository = TimerAssessmentRepository()
    var editingAssessmentItem: AssessmentItem?
    var assessmentItem: AssessmentItem?
    @IBOutlet weak private var assessmentItemNameTextField: UITextField!
    // MARK: -ここまで完了。
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mode = mode else {
            fatalError("mode の中身がありません。メソッド名：[\(#function)]")
        }
        // MARK: - テキストフィールドに名前を設定
        assessmentItemNameTextField.text = getName(mode: mode)
        configueColor()
    }
    // MARK: - Method
    private func getName(mode: Mode) -> String? {
        switch mode {
        case .input:
            return ""
        case .edit:
            guard let editingTargetPersonUUID = editingTargetPersonUUID else {
                fatalError("editingAssessorUUID の中身がありません。メソッド名：[\(#function)]")
            }
            let targetPersonName = timerAssessmentRepository.loadTargetPerson(
                targetPersonUUID: editingTargetPersonUUID
            )?.name
            return targetPersonName
        }
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

    // MARK: - 対象者データを保存するUIButtonのIBAction
    @IBAction private func saveAction(_ sender: Any) {
        guard let mode = mode else { return }

        switch mode {
        case .input:
            let newTargetPerson = TargetPerson(name: targetPersonNameTextField.text ?? "")
            timerAssessmentRepository.appendTargetPerson(assessorUUID: assessorUUID!, targetPerson: newTargetPerson)

        case .edit:
            guard let editingTargetPersonUUID = editingTargetPersonUUID else {
                fatalError("editingTargetPersonUUID　の中身がありません。メソッド名：[\(#function)]")
            }
            let targetPerson = TargetPerson(
                uuidString: editingTargetPersonUUID.uuidString,
                name: targetPersonNameTextField.text ?? ""
            )
            timerAssessmentRepository.updateTargetPerson(targetPerson: targetPerson)
        }

        performSegue(
            withIdentifier: "save",
            sender: sender
        )
    }
}
