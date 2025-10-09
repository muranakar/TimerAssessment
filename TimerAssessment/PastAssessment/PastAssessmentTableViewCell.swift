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
    @IBOutlet weak private var shareTextButton: UIButton! {
        didSet {
            shareTextButton.tintColor = Colors.mainColor
        }
    }
    private var copyAssessmentTextHandler: () -> Void = {  }
    private var shareAssessmentTextHandler: () -> Void = {  }

    @IBAction private func copyAssessmentResult(_ sender: Any) {
        copyAssessmentTextHandler()
    }

    @IBAction private func shareAssessmentResult(_ sender: Any) {
        shareAssessmentTextHandler()
    }

    func configure(
        timerResultNumLabelString: String,
        createdAtLabelString: String,
        copyAssessmentTextHandler: @escaping() -> Void,
        shareAssessmentTextHandler: @escaping() -> Void
    ) {
        timerResultNumLabel.text = timerResultNumLabelString
        createdAtLabel.text = createdAtLabelString
        self.copyAssessmentTextHandler = copyAssessmentTextHandler
        self.shareAssessmentTextHandler = shareAssessmentTextHandler
    }
}
