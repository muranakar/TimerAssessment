//
//  CopyAndPasteFunctionDetailAssessment.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/05.
//

import Foundation

final class CopyAndPasteFunctionAssessment {
    init(timerAssessment: TimerAssessment) {
        self.timerAssessment = timerAssessment
    }
    let timerAssessmentRepository = TimerAssessmentRepository()

    private var timerAssessment: TimerAssessment
    private var assessmentItem: AssessmentItem? {
        timerAssessmentRepository.loadAssessmentItem(timerAssessment: timerAssessment)
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

    var copyAndPasteString: String {
        guard let creatAt = timerAssessment.createdAt else {
            fatalError("creatAtに値が入っていませんメソッド名：[\(#function)]")
        }
        let creatAtString = createdAtdateFormatter(date: creatAt)

        var result = "評価結果\n評価日:\(creatAtString)\n評価者:\(assessor!.name)\n対象者:\(targetPerson!.name)\n評価項目:\(assessmentItem!.name)\n評価結果:\(resultTimerStringFormatter(resultTimer: timerAssessment.resultTimer))"

        // メモがある場合は追加
        if let memo = timerAssessment.memo, !memo.isEmpty {
            result += "\nメモ:\(memo)"
        }

        return result
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

    private func createdAtdateFormatter(date: Date) -> String {
        let dateFormatter = Foundation.DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "yyyy'年'MM'月'dd'日' HH'時'mm'分'"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
