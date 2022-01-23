//
//  FIMTableViewCell.swift
//  FunctionalIndependenceMeasure
//
//  Created by 村中令 on 2021/12/27.
//

import UIKit

final class FIMTableViewCell: UITableViewCell {
    @IBOutlet weak private var sumAllLabel: UILabel!
    @IBOutlet weak private var sumTheMotorSubscaleIncludesLabel: UILabel!
    @IBOutlet weak private var sumTheCognitionSubscaleIncludesLabel: UILabel!
    @IBOutlet weak private var createdAtLabel: UILabel!
    @IBOutlet weak private var updatedAtLabel: UILabel!
    // 【あとからボタンを追加した際のコードに関して】
    //　あとからボタンを追加しました（copytextButton）。そのボタンに色を付けたい場合、
    // 毎回configueメソッドの引数に、UIColorを設定して、メソッド内で、copytextButton = color【←引数（UIColor）】と設定しないと行けないのか。
    //　他にも、Viewの設定（文字の設定、角丸の設定など）、追加したい項目が増えて来るたびに、引数に設定して、tableviewのcellForRowAtで引数に入力しなければならないのか。
    @IBOutlet weak private var copytextButton: UIButton! {
        didSet {
            copytextButton.tintColor = Colors.mainColor
        }
    }
    private var copyFIMTextHandler: () -> Void = {  }

    @IBAction private func copyFIMText(_ sender: Any) {
        copyFIMTextHandler()
    }

    func configure(
        fim: FIM,
        createdAt: String,
        updatedAt: String,
        copyFIMTextHandler: @escaping() -> Void
    ) {
        sumAllLabel.text = String(fim.sumAll)
        sumTheMotorSubscaleIncludesLabel.text = String(fim.sumTheMotorSubscaleIncludes)
        sumTheCognitionSubscaleIncludesLabel.text = String(fim.sumTheCognitionSubscaleIncludes)
        createdAtLabel.text = createdAt
        updatedAtLabel.text = updatedAt
        self.copyFIMTextHandler = copyFIMTextHandler
    }
}
