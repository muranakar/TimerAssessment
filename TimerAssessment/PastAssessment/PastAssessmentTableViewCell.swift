//
//  PastAssessmentTableViewCell.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/06.
//

import UIKit

final class PastAssessmentTableViewCell: UITableViewCell {
    @IBOutlet weak private var timerResultNumLabel: UILabel! {
        didSet {
            timerResultNumLabel.font = UIFont.monospacedDigitSystemFont (ofSize: 25, weight: .medium)
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
        timerResultNumLabelString: String,
        createdAtLabelString: String,
        copyAssessmentTextHandler: @escaping() -> Void
    ) {
        timerResultNumLabel.text = timerResultNumLabelString
        createdAtLabel.text = createdAtLabelString
        self.copyAssessmentTextHandler = copyAssessmentTextHandler
    }
}
