//
//  DetailAssessmentViewController.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/01.
//

import UIKit

final class DetailAssessmentViewController: UIViewController {
    //　画面遷移で値を受け取る変数
    var timerAssessment: TimerAssessment?

    private let timerAssessmentRepository = TimerAssessmentRepository()

    private var assessmentItem: AssessmentItem? {
        timerAssessmentRepository.loadAssessmentItem(timerAssessment: timerAssessment!)
    }
    private var targetPerson: TargetPerson? {
        guard let assessmentItem = assessmentItem else {
            return nil
        }
        return timerAssessmentRepository.loadTargetPerson(assessmentItem: assessmentItem)
    }
    private var assessor: Assessor? {
        guard let targetPerson = targetPerson else {
            return nil
        }
        return timerAssessmentRepository.loadAssessor(targetPerson: targetPerson)
    }

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
        targetPersonLabel.text = targetPerson?.name
        assessmentItemLabel.text = assessmentItem?.name
        assessmentResultLabel.text = resultTimerStringFormatter(resultTimer: timerAssessment!.resultTimer)
    }

    @IBAction private func copyButton(_ sender: Any) {
        UIPasteboard.general.string = CopyAndPasteFunctionAssessment(
            timerAssessment: timerAssessment!
        ).copyAndPasteString
        copyButtonPushAlert(
            title: "コピー完了",
            message: "評価データのコピーが\n完了しました。"
        )
    }

    // MARK: - UIAlertController
    private func copyButtonPushAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - Formatter　Double・Date型→String型へ変更
    private func resultTimerStringFormatter(resultTimer: Double) -> String {
        // 整数部分
        let integer = Int(resultTimer)
        // 小数部分
        let fraction = resultTimer.truncatingRemainder(dividingBy: 1)

        var string = ""
        let hour = integer / 3600
        let min = integer / 60
        let sec = integer % 60
        let fracitonConversion = Int(fraction * 100)
        // １時間以上経過していた場合
        if hour > 0 {
            string = String(format: "%02d時%02d分%02d秒%02d", hour, min, sec, fracitonConversion)
            return string
        }
        // １分以上経過していた場合
        if min > 0 {
            string = String(format: "%02d分%02d秒%02d", min, sec, fracitonConversion)
            return string
        }
        // １分未満の場合
        string = String(format: "%02d秒%02d", sec, fracitonConversion)
        return string
    }
}
