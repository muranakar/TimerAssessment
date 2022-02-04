//
//  DetailAssessmentViewController.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/01.
//

import UIKit

class DetailAssessmentViewController: UIViewController {
    //　画面遷移で値を受け取る変数
    var assessmentItem: AssessmentItem?

    private let timerAssessmentRepository = TimerAssessmentRepository()

    @IBOutlet weak private var targetPersonLabel: UILabel!
    @IBOutlet weak private var assessmentItemLabel: UILabel!
    @IBOutlet weak private var assessmentResultLabel: UILabel!

    enum Mode {
        case assessment
        case pastAssessment
    }
    var mode: Mode?



    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction private func copyButton(_ sender: Any) {
        UIPasteboard.general.string = ""
        copyButtonPushAlert(title: "コピー完了", message: "FIMデータ内容のコピーが\n完了しました。")
    }
    // MARK: - UIAlertController
    private func copyButtonPushAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
