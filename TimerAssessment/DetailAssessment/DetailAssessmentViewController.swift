//
//  DetailAssessmentViewController.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/01.
//

import UIKit

final class DetailAssessmentViewController: UIViewController {
    //　画面遷移で値を受け取る変数
    var timerAssessment: TimerAssessment?

    private let timerAssessmentRepository = TimerAssessmentRepository()

    private var assessmentItem: AssessmentItem? {
        timerAssessmentRepository.loadAssessmentItem(timerAssessment: timerAssessment!)
    }
    private var targetPerson: TargetPerson? {
        guard let assessmentItem = assessmentItem else {
            return nil
        }
        return timerAssessmentRepository.loadTargetPerson(assessmentItem: assessmentItem)
    }
    private var assessor: Assessor? {
        guard let targetPerson = targetPerson else {
            return nil
        }
        return timerAssessmentRepository.loadAssessor(targetPerson: targetPerson)
    }

    // MARK: - UI Components
    private let targetPersonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "対象者"
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let targetPersonLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 26)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let assessmentItemTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "評価項目"
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let assessmentItemLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let assessmentResultTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "評価結果"
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let assessmentResultLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let copyButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = "copy"
        config.image = UIImage(systemName: "doc.on.doc")
        config.imagePlacement = .top
        config.imagePadding = 8
        config.baseForegroundColor = .systemBlue
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    enum Mode {
        case assessment
        case pastAssessment
    }
    var mode: Mode?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(targetPersonTitleLabel)
        view.addSubview(targetPersonLabel)
        view.addSubview(assessmentItemTitleLabel)
        view.addSubview(assessmentItemLabel)
        view.addSubview(assessmentResultTitleLabel)
        view.addSubview(assessmentResultLabel)
        view.addSubview(copyButton)

        NSLayoutConstraint.activate([
            // Target Person Title
            targetPersonTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            targetPersonTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            targetPersonTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            targetPersonTitleLabel.heightAnchor.constraint(equalToConstant: 21),

            // Target Person Label
            targetPersonLabel.topAnchor.constraint(equalTo: targetPersonTitleLabel.bottomAnchor, constant: 30),
            targetPersonLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            targetPersonLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            targetPersonLabel.heightAnchor.constraint(equalToConstant: 30),

            // Assessment Item Title
            assessmentItemTitleLabel.topAnchor.constraint(equalTo: targetPersonLabel.bottomAnchor, constant: 70),
            assessmentItemTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            assessmentItemTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            assessmentItemTitleLabel.heightAnchor.constraint(equalToConstant: 21),

            // Assessment Item Label
            assessmentItemLabel.topAnchor.constraint(equalTo: assessmentItemTitleLabel.bottomAnchor, constant: 30),
            assessmentItemLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            assessmentItemLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            assessmentItemLabel.heightAnchor.constraint(equalToConstant: 30),

            // Assessment Result Title
            assessmentResultTitleLabel.topAnchor.constraint(equalTo: assessmentItemLabel.bottomAnchor, constant: 70),
            assessmentResultTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            assessmentResultTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            assessmentResultTitleLabel.heightAnchor.constraint(equalToConstant: 21),

            // Assessment Result Label
            assessmentResultLabel.topAnchor.constraint(equalTo: assessmentResultTitleLabel.bottomAnchor, constant: 30),
            assessmentResultLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            assessmentResultLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            assessmentResultLabel.heightAnchor.constraint(equalToConstant: 30),

            // Copy Button
            copyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            copyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64),
            copyButton.widthAnchor.constraint(equalToConstant: 100),
            copyButton.heightAnchor.constraint(equalToConstant: 100)
        ])

        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
    }

    private func loadData() {
        targetPersonLabel.text = targetPerson?.name
        assessmentItemLabel.text = assessmentItem?.name
        assessmentResultLabel.text = resultTimerStringFormatter(resultTimer: timerAssessment!.resultTimer)
    }

    @objc private func copyButtonTapped() {
        UIPasteboard.general.string = CopyAndPasteFunctionAssessment(
            timerAssessment: timerAssessment!
        ).copyAndPasteString
        copyButtonPushAlert(
            title: "コピー完了",
            message: "評価データのコピーが\n完了しました。"
        )
    }

    // MARK: - UIAlertController
    private func copyButtonPushAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - Formatter　Double・Date型→String型へ変更
    private func resultTimerStringFormatter(resultTimer: Double) -> String {
        // 整数部分
        let integer = Int(resultTimer)
        // 小数部分
        let fraction = resultTimer.truncatingRemainder(dividingBy: 1)

        var string = ""
        let hour = integer / 3600
        let min = integer / 60
        let sec = integer % 60
        let fracitonConversion = Int(fraction * 100)
        // １時間以上経過していた場合
        if hour > 0 {
            string = String(format: "%02d時%02d分%02d秒%02d", hour, min, sec, fracitonConversion)
            return string
        }
        // １分以上経過していた場合
        if min > 0 {
            string = String(format: "%02d分%02d秒%02d", min, sec, fracitonConversion)
            return string
        }
        // １分未満の場合
        string = String(format: "%02d秒%02d", sec, fracitonConversion)
        return string
    }
}
