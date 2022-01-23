//
//  DetailFIMTableViewCell.swift
//  FunctionalIndependenceMeasure
//
//  Created by 村中令 on 2021/12/23.
//

import UIKit

final class DetailTextBoldFIMTableViewCell: UITableViewCell {
    @IBOutlet private weak var fimItemTitleLabel: UILabel!
    @IBOutlet private weak var fimItemNumLabel: UILabel!

    func configure(fimItemTitle: String, fimItemNum: String) {
        fimItemTitleLabel.text = fimItemTitle
        fimItemNumLabel.text = fimItemNum
    }
}
