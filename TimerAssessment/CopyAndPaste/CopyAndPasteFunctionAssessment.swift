//
//  CopyAndPasteFunctionDetailAssessment.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/05.
//

import Foundation

class CopyAndPasteFunctionAssessment {
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
        let creatAtString = dateFormatter(date: creatAt)

    //     swiftlint:disable:next line_length
        return "評価結果\n評価日\(creatAtString)\n評価者:\(assessor!.name)\n対象者:\(targetPerson!.name)\n評価項目\(assessmentItem!.name)\n評価結果:\(String(timerAssessment.resultTimer) + "　秒")"
    }

    // MARK: - DateFormatter　Date型→String型へ変更
    func dateFormatter(date: Date) -> String {
        let dateFormatter = Foundation.DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
