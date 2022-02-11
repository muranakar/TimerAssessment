//
//  AssessmentItemTableViewCell.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/01/31.
//

import UIKit

final class AssessmentItemTableViewCell: UITableViewCell {
    @IBOutlet private weak var assessmentItemName: UILabel!

    func configue(name: String) {
        assessmentItemName.text = name
    }
}
