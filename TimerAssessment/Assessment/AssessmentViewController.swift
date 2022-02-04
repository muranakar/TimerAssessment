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
    private var timerMode: TimerMode?

    deinit {
        print("Released👍🏻: \(self)")
    }

    // MARK: - IBOutlet
    @IBOutlet private weak var sec: UILabel!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var stopButton: UIButton!
    @IBOutlet private weak var resetButton: UIButton!

    // MARK: - Variable constant
    private var startTime = CFAbsoluteTimeGetCurrent()
    private var stopTime = CFAbsoluteTimeGetCurrent()

    // MARK: - Method
    override func viewDidLoad() {
        super.viewDidLoad()
        stopButton.isEnabled = false
    }

    @IBAction private func save(_ sender: Any) {
        if timerMode == nil || timerMode == .start || timerMode == .reset {
            timerAlert()
            timerMode = .reset
            disPlayLink.invalidate()
            assessmentResultNum = nil
            sec.text = "0"
            stopButton.isEnabled = false
            return
        }
        guard let stopTimerNum = assessmentResultNum else {
        print("メソッド名：[\(#function)] stopTimerNumに値が入っていない。")
            return
        }
        let newTruncationStopTimerNum = floor(stopTimerNum * 100) / 100
        let newTimerAssessment = TimerAssessment(resultTimer: newTruncationStopTimerNum)
        timerAssessmetRepository.appendTimerAssessment(
            assessmentItem: assessmentItem!,
            timerAssessment: newTimerAssessment
        )
    }

    @IBAction private func start(_ sender: Any) {
        timerMode = .start
        disPlayLink.add(runloop: .main, forMode: .common)
        startTime = CFAbsoluteTimeGetCurrent()
        assessmentResultNum = nil
        stopButton.isEnabled = true
    }

    @IBAction private func stop(_ sender: Any) {
        timerMode = .stop
        disPlayLink.invalidate()
        stopTime = CFAbsoluteTimeGetCurrent() - startTime
        assessmentResultNum = Double(stopTime)
        sec.text = "\(floor(stopTime*100)/100)"
        stopButton.isEnabled = false
    }
    @IBAction private func reset(_ sender: Any) {
        timerMode = .reset
        disPlayLink.invalidate()
        assessmentResultNum = nil
        sec.text = "0"
        stopButton.isEnabled = false
    }

    @objc func step(displaylink: CADisplayLink) {
        stopTime = CFAbsoluteTimeGetCurrent() - startTime
        sec.text = "\(floor(stopTime*100)/100)"
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
