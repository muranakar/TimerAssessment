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

    // MARK: - IBOutlet
    @IBOutlet private weak var saveBarButton: UIBarButtonItem!
    @IBOutlet private weak var assessmentItemLabel: UILabel!
    @IBOutlet private weak var timerLabel: UILabel!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var stopButton: UIButton!
    @IBOutlet private weak var resetButton: UIButton!

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
        assessmentItemLabel.text = assessmentItem?.name
        stopButton.isEnabled = false
        saveBarButton.isEnabled = false
        configueViewButtonsStyle()
        configueViewTimerLabel()
    }

    @IBAction private func save(_ sender: Any) {
        if timerMode == nil || timerMode == .start || timerMode == .reset {
            timerAlert()
            timerMode = .reset
            disPlayLink.invalidate()
            assessmentResultNum = nil
            timerLabel.text = "0"
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
        toDetailAssessmentViewController(timerAssessment: timerAssessment!)
    }

    @IBAction private func start(_ sender: Any) {
        timerMode = .start
        disPlayLink.add(runloop: .main, forMode: .common)
        startTime = CFAbsoluteTimeGetCurrent()
        assessmentResultNum = nil
        stopButton.isEnabled = true
        saveBarButton.isEnabled = false
    }

    @IBAction private func stop(_ sender: Any) {
        timerMode = .stop
        disPlayLink.invalidate()

        stopTime = CFAbsoluteTimeGetCurrent() - startTime
        assessmentResultNum = stopTime
        let stopTimerString = timerFormatter(stopTime: stopTime)
        timerLabel.text = stopTimerString
        stopButton.isEnabled = false
        saveBarButton.isEnabled = true
    }
    @IBAction private func reset(_ sender: Any) {
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
    // MARK: - Method
    private func toDetailAssessmentViewController(timerAssessment: TimerAssessment?) {
        let storyboard = UIStoryboard(name: "DetailAssessment", bundle: nil)
        let nextVC = storyboard.instantiateViewController(
            withIdentifier: "detailAssessment"
        ) as! DetailAssessmentViewController
        nextVC.timerAssessment = timerAssessment
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
    private func configueViewButtonsStyle() {
        // 選択ボタンのView
        buttons.forEach {
            $0.backgroundColor = Colors.baseColor
            $0.setTitleColor(Colors.mainColor, for: .normal)
            $0.layer.cornerRadius = 40
            $0.layer.borderWidth = 2
            $0.layer.borderColor = Colors.mainColor.cgColor
            $0.layer.shadowOpacity = 0.5
            $0.layer.shadowRadius = 2
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 1, height: 1)
        }
    }

    private func configueViewTimerLabel() {
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 60, weight: .medium)
    }
}

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
