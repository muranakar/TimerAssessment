//
//  InputTargetPersonViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

final class InputTargetPersonViewController: UIViewController {
    // 画面遷移時に値を受け取る変数
    var assessorUUID: UUID?
    enum Mode {
        case input
        case edit
    }

    var mode: Mode?
    private let fimRepository = FIMRepository()
    var editingTargetPersonUUID: UUID?
    var targetPerson: TargetPerson?
    @IBOutlet weak private var targetPersonNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mode = mode else {
            fatalError("mode の中身がありません。メソッド名：[\(#function)]")
        }
        // MARK: - テキストフィールドに名前を設定
        targetPersonNameTextField.text = getName(mode: mode)
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
            let targetPersonName = fimRepository.loadTargetPerson(targetPersonUUID: editingTargetPersonUUID)?.name
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
            let newTargetPerson = TargetPerson()
            newTargetPerson.name = targetPersonNameTextField.text ?? ""
            fimRepository.appendTargetPerson(assessorUUID: assessorUUID!, targetPerson: newTargetPerson)
        case .edit:
            guard let editingTargetPersonUUID = editingTargetPersonUUID else {
                fatalError("editingTargetPersonUUID　の中身がありません。メソッド名：[\(#function)]")
            }

            let editingTargetPersonName = targetPersonNameTextField.text ?? ""
            fimRepository.updateTargetPerson(
                uuid: editingTargetPersonUUID,
                name: editingTargetPersonName
            )
        }

        performSegue(
            withIdentifier: "save",
            sender: sender
        )
    }
}
