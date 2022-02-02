//
//  InputAssessmentItemViewController.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/01/31.
//

import UIKit

final class InputAssessmentItemViewController: UIViewController {
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
            return editingAssessmentItem?.name
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
    // MARK: - ここまで完了。
    // MARK: - 対象者データを保存するUIButtonのIBAction
    @IBAction private func saveAction(_ sender: Any) {
        guard let mode = mode else { return }

        switch mode {
        case .input:
            let newAssessmentItem = AssessmentItem(name: assessmentItemNameTextField.text ?? "")
            timerAssessmentRepository.appendAssessmentItem(
                targetPerson: targetPerson!,
                assessmentItem: newAssessmentItem
            )

        case .edit:
            let assessmentItem: AssessmentItem = AssessmentItem(
                uuidString: editingAssessmentItem!.uuidString,
                name: assessmentItemNameTextField.text ?? ""
            )
            timerAssessmentRepository.updateAssessmentItem(assessmentItem: assessmentItem)
        }

        performSegue(
            withIdentifier: "save",
            sender: sender
        )
    }
}
