//
//  TargetPersonTableViewCell.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

final class TargetPersonTableViewCell: UITableViewCell {
    @IBOutlet private weak var tagetPeronName: UILabel!

    func configue(name: String) {
        tagetPeronName.text = name
    }
}
