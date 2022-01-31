//
//  AssessmentItemTableViewCell.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/01/31.
//

import UIKit

class AssessmentItemTableViewCell: UITableViewCell {
    @IBOutlet private weak var tagetPeronName: UILabel!

    func configue(name: String) {
        tagetPeronName.text = name
    }
}
