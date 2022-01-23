//
//  AssessorTableViewCell.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

final class AssessorTableViewCell: UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
//　サンプル　後で消す
    func configue(assessor: Assessor) {
        nameLabel.text = assessor.name
    }
}
