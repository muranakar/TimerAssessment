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
    @IBOutlet private weak var tenMeterWalkTestButton: UIButton!
    @IBOutlet private weak var sixMinutesWalkingButton: UIButton!
    @IBOutlet private weak var rightOneLegStandingButton: UIButton!
    @IBOutlet private weak var leftOneLegStandingButton: UIButton!
    @IBOutlet private weak var tugTestButton: UIButton!

    private var buttons: [UIButton] {
        [
            tenMeterWalkTestButton,
            sixMinutesWalkingButton,
            rightOneLegStandingButton,
            leftOneLegStandingButton,
            tugTestButton
        ]
    }

    private var buttonString: [String] {
        [
            "１０ｍ歩行",
            "６分間歩行",
            "片脚立位（右）",
            "片脚立位（左）",
            "TUG"
        ]
    }

    private var dictionaryButtonAndButtonString: [UIButton: String] {
        [UIButton: String](uniqueKeysWithValues: zip(buttons, buttonString))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mode = mode else {
            fatalError("mode の中身がありません。メソッド名：[\(#function)]")
        }
        // MARK: - テキストフィールドに名前を設定
        assessmentItemNameTextField.text = getName(mode: mode)
        configueColor()
    }

    override func viewDidLayoutSubviews() {
        buttons.forEach { configueViewAssessmentItemButton(button: $0) }
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

    @IBAction private func selectedButtonList(sender: UIButton) {
        guard let mode = mode else { return }
        guard let newAssementItemName = dictionaryButtonAndButtonString[sender] else {
            return
        }
        switch mode {
        case .input:
            let newAssessmentItem = AssessmentItem(
                name: newAssementItemName
            )
            timerAssessmentRepository.appendAssessmentItem(
                targetPerson: targetPerson!,
                assessmentItem: newAssessmentItem
            )

        case .edit:
            let assessmentItem: AssessmentItem = AssessmentItem(
                uuidString: editingAssessmentItem!.uuidString,
                name: newAssementItemName
            )
            timerAssessmentRepository.updateAssessmentItem(assessmentItem: assessmentItem)
        }

        performSegue(
            withIdentifier: "save",
            sender: sender
        )
    }

    private func configueViewAssessmentItemButton(button: UIButton) {
        button.backgroundColor = Colors.baseColor
        button.setTitleColor(Colors.mainColor, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = Colors.mainColor.cgColor
        button.layer.shadowOpacity = 0.7
        button.layer.shadowRadius = 3
        button.layer.shadowColor = Colors.mainColor.cgColor
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    }
}
