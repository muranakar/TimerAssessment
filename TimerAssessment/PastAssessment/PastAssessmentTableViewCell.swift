//
//  PastAssessmentTableViewCell.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/06.
//

import UIKit

class PastAssessmentTableViewCell: UITableViewCell {
    @IBOutlet weak private var timerResultNumLabel: UILabel! {
        didSet {
            let attributedText = NSMutableAttributedString(
                string: timerResultNumLabel.text!
            )
            let customLetterSpacing = 3
            attributedText
                .addAttribute(
                    NSAttributedString.Key.kern,
                    value: customLetterSpacing,
                    range: NSMakeRange(0, attributedText.length)
                )
            timerResultNumLabel.attributedText = attributedText
            timerResultNumLabel.sizeToFit()
        }
    }
    @IBOutlet weak private var createdAtLabel: UILabel!

    @IBOutlet weak private var copyTextButton: UIButton! {
        didSet {
            copyTextButton.tintColor = Colors.mainColor
        }
    }
    private var copyAssessmentTextHandler: () -> Void = {  }

    @IBAction private func copyAssessmentResult(_ sender: Any) {
        copyAssessmentTextHandler()
    }

    func configure(
        timerAssessment: TimerAssessment,
        createdAt: String,
        copyAssessmentTextHandler: @escaping() -> Void
    ) {
        timerResultNumLabel.text = String(timerAssessment.resultTimer) + " 秒"
        createdAtLabel.text = createdAt
        self.copyAssessmentTextHandler = copyAssessmentTextHandler
    }
}
