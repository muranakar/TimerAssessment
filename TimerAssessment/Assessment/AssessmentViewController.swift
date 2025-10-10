//
//  AssessmentViewController.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/01.
//

import UIKit

final class AssessmentViewController: UIViewController {
    enum TimerMode {
        case start
        case stop
        case reset
    }
    // 変数の受け皿
    var assessmentItem: AssessmentItem?
    private lazy var disPlayLink = DisplayLinkWrapper { [weak self] sender in
        self?.step(displaylink: sender)
    }
    let timerAssessmetRepository = TimerAssessmentRepository()
    private var assessmentResultNum: Double?
    private var timerAssessment: TimerAssessment?
    private var timerMode: TimerMode?

    deinit {
        print("Released👍🏻: \(self)")
    }

    // MARK: - UI Components
    private let assessmentItemTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "評価項目"
        label.font = .boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let assessmentItemLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.font = .monospacedDigitSystemFont(ofSize: 60, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let startButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "start"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .medium

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let stopButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "stop"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemRed
        config.cornerStyle = .medium

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let resetButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "reset"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemGray
        config.cornerStyle = .medium

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var saveBarButton: UIBarButtonItem!

    // MARK: - Variable constant
    private var buttons: [UIButton] {
        [
            startButton, stopButton, resetButton
        ]
    }
    private var startTime = CFAbsoluteTimeGetCurrent()
    private var stopTime = CFAbsoluteTimeGetCurrent()

    // MARK: - Method
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadData()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(assessmentItemTitleLabel)
        view.addSubview(assessmentItemLabel)
        view.addSubview(timerLabel)
        view.addSubview(startButton)
        view.addSubview(stopButton)
        view.addSubview(resetButton)

        NSLayoutConstraint.activate([
            // Title Label
            assessmentItemTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            assessmentItemTitleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -220),

            // Assessment Item Label
            assessmentItemLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            assessmentItemLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            assessmentItemLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            assessmentItemLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -170),

            // Timer Label
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),

            // Start Button
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 60),
            startButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8),
            startButton.heightAnchor.constraint(equalToConstant: 70),

            // Stop Button
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            stopButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8),
            stopButton.heightAnchor.constraint(equalToConstant: 70),

            // Reset Button
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 20),
            resetButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8),
            resetButton.heightAnchor.constraint(equalToConstant: 70)
        ])

        startButton.addTarget(self, action: #selector(start), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stop), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)

        stopButton.isEnabled = false
        updateButtonFontSizes()
    }

    private func setupNavigationBar() {
        saveBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        saveBarButton.isEnabled = false
        navigationItem.rightBarButtonItem = saveBarButton

        // カスタム戻るボタン
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "戻る",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }

    @objc private func backButtonTapped() {
        // 未保存のデータがあるかチェック
        if hasUnsavedData() {
            showUnsavedDataAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    // 未保存のデータがあるかチェック
    private func hasUnsavedData() -> Bool {
        // タイマーが停止状態で、測定結果が00:00:00以外の場合
        if timerMode == .stop, let result = assessmentResultNum, result > 0 {
            return true
        }
        return false
    }

    // 未保存データがある場合のアラート
    private func showUnsavedDataAlert() {
        let alert = UIAlertController(
            title: "測定結果が保存されていません",
            message: "測定結果を記録しますか？\nそれとも画面を戻りますか？",
            preferredStyle: .alert
        )

        // 記録する
        alert.addAction(UIAlertAction(
            title: "記録する",
            style: .default,
            handler: { [weak self] _ in
                self?.save()
            }
        ))

        // 破棄して戻る
        alert.addAction(UIAlertAction(
            title: "破棄して戻る",
            style: .destructive,
            handler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
        ))

        // キャンセル
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))

        present(alert, animated: true)
    }

    private func loadData() {
        assessmentItemLabel.text = assessmentItem?.name
    }

    @objc private func save() {
        if timerMode == nil || timerMode == .start || timerMode == .reset {
            timerAlert()
            timerMode = .reset
            disPlayLink.invalidate()
            assessmentResultNum = nil
            timerLabel.text = "00:00:00"
            stopButton.isEnabled = false
            return
        }
        guard let stopTimerNum = assessmentResultNum else {
            print("メソッド名：[\(#function)] stopTimerNumに値が入っていない。")
            return
        }
        let newTruncationStopTimerNum = floor(stopTimerNum * 100) / 100
        timerAssessment = TimerAssessment(resultTimer: newTruncationStopTimerNum)
        timerAssessmetRepository.appendTimerAssessment(
            assessmentItem: assessmentItem!,
            timerAssessment: timerAssessment!
        )

        // 保存後のアラートを表示（測定結果画面への遷移は行わない）
        showSaveCompletedAlert()

        // 測定値をリセット
        resetAndContinue()
    }

    // 保存完了アラート
    private func showSaveCompletedAlert() {
        guard let timerAssessment = timerAssessment else { return }

        let resultString = timerFormatter(stopTime: timerAssessment.resultTimer)

        let alert = UIAlertController(
            title: "保存されました",
            message: "測定結果: \(resultString)",
            preferredStyle: .alert
        )

        // 続けて記録する
        alert.addAction(UIAlertAction(
            title: "続けて記録",
            style: .default,
            handler: { [weak self] _ in
                self?.resetAndContinue()
            }
        ))

        // 過去評価を見る
        alert.addAction(UIAlertAction(
            title: "過去評価を見る",
            style: .default,
            handler: { [weak self] _ in
                self?.toPastAssessmentViewController()
            }
        ))

        // 戻る
        alert.addAction(UIAlertAction(
            title: "戻る",
            style: .default,
            handler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
        ))

        present(alert, animated: true)
    }

    // リセットして続けて測定
    private func resetAndContinue() {
        timerMode = .reset
        disPlayLink.invalidate()
        assessmentResultNum = nil
        timerLabel.text = "00:00:00"
        stopButton.isEnabled = false
        saveBarButton.isEnabled = false
        timerAssessment = nil
    }

    @objc private func start() {
        timerMode = .start
        disPlayLink.add(runloop: .main, forMode: .common)
        startTime = CFAbsoluteTimeGetCurrent()
        assessmentResultNum = nil
        stopButton.isEnabled = true
        saveBarButton.isEnabled = false
    }

    @objc private func stop() {
        timerMode = .stop
        disPlayLink.invalidate()

        stopTime = CFAbsoluteTimeGetCurrent() - startTime
        assessmentResultNum = stopTime
        let stopTimerString = timerFormatter(stopTime: stopTime)
        timerLabel.text = stopTimerString
        stopButton.isEnabled = false
        saveBarButton.isEnabled = true
    }
    @objc private func reset() {
        timerMode = .reset
        disPlayLink.invalidate()
        assessmentResultNum = nil
        timerLabel.text = "00:00:00"
        stopButton.isEnabled = false
        saveBarButton.isEnabled = false
    }

    @objc func step(displaylink: CADisplayLink) {
        stopTime = CFAbsoluteTimeGetCurrent() - startTime
        let stopTimerString = timerFormatter(stopTime: stopTime)
        timerLabel.text = stopTimerString
    }
    // MARK: - Navigation
    private func toDetailAssessmentViewController(timerAssessment: TimerAssessment?) {
        let nextVC = DetailAssessmentViewController()
        nextVC.timerAssessment = timerAssessment
        navigationController?.pushViewController(nextVC, animated: true)
    }

    private func toPastAssessmentViewController() {
        let storyboard = UIStoryboard(name: "PastAssessment", bundle: nil)
        guard let nextVC = storyboard.instantiateViewController(withIdentifier: "pastAssessment") as? PastAssessmentViewController else {
            return
        }
        nextVC.assessmentItem = assessmentItem
        navigationController?.pushViewController(nextVC, animated: true)
    }
    // MARK: - UIUIAlertController
    private func timerAlert() {
        // 部品のアラートを作る
        let alertController = UIAlertController(
            title: "計測結果がありません",
            message: "Startボタンを押してから、\nStopボタンを押して、\n計測を行ってください。",
            preferredStyle: .alert
        )
        // OKボタン追加
        let okAction = UIAlertAction(
            title: "OK",
            style: .default
        )
        alertController.addAction(okAction)
        // アラートを表示する
        present(alertController, animated: true, completion: nil)
    }
    // MARK: - DateFormatter　Date型→String型へ変更
    func timerFormatter(stopTime: CFAbsoluteTime) -> String {
        let min = Int(stopTime / 60)
        let sec = Int(stopTime) % 60
        let stopTimeDouble = Double(stopTime)
        let fracitonstopTimer = stopTimeDouble.truncatingRemainder(dividingBy: 1)
        let msec = Int(fracitonstopTimer * 100.0)
        let stopTimerString = String(format: "%02d:%02d:%02d", min, sec, msec)
        return stopTimerString
    }

    // MARK: - ViewConfigue
    private func updateButtonFontSizes() {
        let fontSize: CGFloat = 24

        buttons.forEach { button in
            var config = button.configuration
            config?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
                return outgoing
            }
            button.configuration = config
        }
    }
}

// MARK: - DisplayLinkWrapper

private final class DisplayLinkWrapper {
    private var handler = Handler()
    private var disPlayLink: CADisplayLink? {
        didSet {
            oldValue?.invalidate()
        }
    }
    var preferredFramesPerSecond = Int.zero

    // switchでの、　some noneは何を実行しているのかがわかっていない。
    init(_ onUpdate: @escaping (CADisplayLink) -> Void) {
        handler = Handler { [weak self] disPlayLink in
            // このselfは、DisplayLinkWrapperを示していると考えているが、
            // classがOptionalとはどう云う意味かが理解できない。。
            switch self {
            case .some:
                onUpdate(disPlayLink)
            case .none:
                disPlayLink.invalidate()
            }
        }
    }

    deinit {
        disPlayLink?.invalidate()
    }

    func add(runloop: RunLoop, forMode mode: RunLoop.Mode) {
        // selectorの中身のHandlerをhandlerに変更
        disPlayLink = .init(target: handler, selector: #selector(handler.callBack(sender:)))
        disPlayLink?.preferredFramesPerSecond = preferredFramesPerSecond
        disPlayLink?.add(to: runloop, forMode: mode)
    }

    func invalidate() {
        disPlayLink?.invalidate()
        disPlayLink = nil
    }

    // disPlayLinkのイニシャライザのtarget,selectorの中で用いられる。
    private final class Handler: NSObject {
        let onUpdate: (CADisplayLink) -> Void

        init(_ onUpdate: @escaping (CADisplayLink) -> Void = { _ in }) {
            self.onUpdate = onUpdate
        }

        @objc
        func callBack(sender: CADisplayLink) {
            self.onUpdate(sender)
        }
    }
}
