//
//  AssessmentViewController.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/01.
//

import UIKit

final class AssessmentViewController: UIViewController {
    // 変数の受け皿
    var assessmentItem: AssessmentItem?
    private lazy var disPlayLink = DisplayLinkWrapper { [weak self] sender in
        self?.step(displaylink: sender)
    }
    let timerAssessmetRepository = TimerAssessmentRepository()
    private var stopTimerNum: Float?

    deinit {
        print("Released👍🏻: \(self)")
    }

    // MARK: - IBOutlet
    @IBOutlet private weak var sec: UILabel!

    // MARK: - Variable constant
    private var startTime = CFAbsoluteTimeGetCurrent()
    private var stopTime = CFAbsoluteTimeGetCurrent()

    // MARK: - Method
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction private func save(_ sender: Any) {
        guard let stopTimerNum = stopTimerNum else {
            // アラート　タイマーで計測されていません。
            return
        }
        let truncationStopTimerNum = floor(stopTimerNum * 100) / 100
        let newTimerAssessment = TimerAssessment(resultTimer: truncationStopTimerNum)
        timerAssessmetRepository.appendTimerAssessment(
            assessmentItem: assessmentItem!,
            timerAssessment: newTimerAssessment
        )
    }

    @IBAction private func start(_ sender: Any) {
        disPlayLink.add(runloop: .main, forMode: .common)
        startTime = CFAbsoluteTimeGetCurrent()
    }

    @IBAction private func stop(_ sender: Any) {
        disPlayLink.invalidate()
        stopTime = CFAbsoluteTimeGetCurrent() - startTime
        let truncation = floor(stopTime * 100 ) / 100
        print("\(truncation)")
        let floatStopTime = Float(truncation)
        print("\(floatStopTime)")
        stopTimerNum = floatStopTime
        print("\(stopTimerNum)")
    }

    @objc func step(displaylink: CADisplayLink) {
        stopTime = CFAbsoluteTimeGetCurrent() - startTime
        sec.text = "\(floor(stopTime*100)/100)"
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
