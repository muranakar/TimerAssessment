//
//  CopyAndPasteFunctionDetailAssessment.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/05.
//

import Foundation

class CopyAndPasteFunction {
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

    var copyAndPasteString: String {
        guard let creatAt = timerAssessment.createdAt else {
            fatalError("creatAtに値が入っていませんメソッド名：[\(#function)]")
        }
        let creatAtString = dateFormatter(date: creatAt)

        // swiftlint:disable:next line_length
//        return "評価結果\n評価日\(creatAt)\n評価者:\(assessor.name)\n対象者:\(targetPerson.name)\n合計値\(sumAll)\n食事:\(eating)\n整容:\(grooming)\n清拭:\(bathing)\n更衣上半身:\(dressingUpperBody)\n更衣下半身:\(dressingLowerBody)\nトイレ動作:\(toileting)\n排尿管理:\(bladderManagement)\n排便管理:\(bowelManagement)\nベッド・椅子・車椅子移乗:\(transfersBedChairWheelchair)\nトイレ移乗:\(transfersToilet)\n浴槽・シャワー移乗:\(transfersBathShower)\n歩行・車椅子:\(walkWheelchair)\n階段:\(stairs)\n理解:\(comprehension)\n表出:\(expression)\n社会的交流:\(socialInteraction)\n問題解決:\(problemSolving)\n記憶:\(memory)"
        return ""
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
