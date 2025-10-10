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

    // プログラマティックに追加するメモラベル（XIBファイル編集不要）
    private let memoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

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

    private var memoLabelSetup = false

    override func awakeFromNib() {
        super.awakeFromNib()
        setupMemoLabel()
    }

    private func setupMemoLabel() {
        guard !memoLabelSetup else { return }
        memoLabelSetup = true

        contentView.addSubview(memoLabel)

        NSLayoutConstraint.activate([
            memoLabel.topAnchor.constraint(equalTo: createdAtLabel.bottomAnchor, constant: 4),
            memoLabel.leadingAnchor.constraint(equalTo: createdAtLabel.leadingAnchor),
            memoLabel.trailingAnchor.constraint(equalTo: copyTextButton.leadingAnchor, constant: -8),
            memoLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    @IBAction private func copyAssessmentResult(_ sender: Any) {
        copyAssessmentTextHandler()
    }

    @IBAction private func shareAssessmentResult(_ sender: Any) {
        shareAssessmentTextHandler()
    }

    func configure(
        timerResultNumLabelString: String,
        createdAtLabelString: String,
        memo: String? = nil,
        copyAssessmentTextHandler: @escaping() -> Void,
        shareAssessmentTextHandler: @escaping() -> Void
    ) {
        timerResultNumLabel.text = timerResultNumLabelString
        createdAtLabel.text = createdAtLabelString

        // メモの表示設定
        if let memo = memo, !memo.isEmpty {
            memoLabel.text = "メモ: \(memo)"
            memoLabel.isHidden = false
        } else {
            memoLabel.text = nil
            memoLabel.isHidden = true
        }

        self.copyAssessmentTextHandler = copyAssessmentTextHandler
        self.shareAssessmentTextHandler = shareAssessmentTextHandler
    }
}
