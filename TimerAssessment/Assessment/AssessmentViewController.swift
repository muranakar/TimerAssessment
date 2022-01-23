//
//  AssessmentViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit
import SwiftUI

final class AssessmentViewController: UIViewController {
    //　画面遷移で値を受け取る変数
    var targetPersonUUID: UUID?
    // 画面遷移先へ値を渡す変数
    var fimUUID: UUID?
    //　FIMの評価結果を入れて、Repositoryのメソッドに代入するための変数
    private var fim: FIM?

    @IBOutlet private weak var progressTextLabel: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var fimItemTitleLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var button1: UIButton!
    @IBOutlet private weak var button2: UIButton!
    @IBOutlet private weak var button3: UIButton!
    @IBOutlet private weak var button4: UIButton!
    @IBOutlet private weak var button5: UIButton!
    @IBOutlet private weak var button6: UIButton!
    @IBOutlet private weak var button7: UIButton!
    @IBOutlet private weak var decisionButton: UIButton!
    @IBOutlet private weak var attentionButton: UIButton!

    private let fimRepository = FIMRepository()

    // FIMの項目を回答した回数のcountする変数
    private var fimItemCount = 0
    private var buttons: [UIButton] {
        [
            button1, button2, button3, button4, button5, button6, button7
        ]
    }

    // 各ボタンと関連付ける際に、用いる文字列の配列。
    // この配列は、FIMの項目ごとに、配列の文字列が変化する。
    private var fimItemText: [String] {
        [
            fimScoringCriteria[fimItemCount].one,
            fimScoringCriteria[fimItemCount].two,
            fimScoringCriteria[fimItemCount].three,
            fimScoringCriteria[fimItemCount].four,
            fimScoringCriteria[fimItemCount].five,
            fimScoringCriteria[fimItemCount].six,
            fimScoringCriteria[fimItemCount].seven
        ]
    }
    //　UIButtonのTag管理を避けるために、ボタンと数字を関連付けるために、用いる数字の配列
    private var fimNum = Array(1...7)

    //　UIButtonが押された際に、そのボタンに合った文章を管理するため、辞書型で関連付けた。
    private var dictionaryButtonAndString: [UIButton: String] {
        [UIButton: String](uniqueKeysWithValues: zip(buttons, fimItemText))
    }

    //　UIButtonが押された際に、そのボタンに合った数字（評価結果）を管理するため、辞書型で関連付けた。
    private var dictionaryButtonAndNum: [UIButton: Int] {
        [UIButton: Int](uniqueKeysWithValues: zip(buttons, fimNum))
    }

    //  FIM項目の結果の数値を、配列で管理。→　WHY：最後にまとめて、FIMのモデルオブジェクトに代入するため。
    private var assessmentResultFIM: [Int] = []

    // JSONファイルから、デコードされた構造体を、配列で管理。
    private var fimScoringCriteria: [FimScoringCriteria] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        decodeFimJsonFile()
        alertController.addAction(defaultAction)
        updateLabelAndProgressView()
        configueViewProgressViewStyle()
        configueViewButtonsStyle()
    }
// FIM項目を一つ戻る
    @IBAction private func backOneFIMItem(_ sender: Any) {
        if fimItemCount >= 1 {
            fimItemCount -= 1
            assessmentResultFIM.removeLast()
            updateScreenAndAllUIButtonIsSelectedFalse()
            configueViewButtonsStyle()
        }
    }

    @IBAction private func selectedFIMNum(sender: UIButton) {
        //　ボタンが選択された際に、そのボタンと関連づけられた文字列を、テキストビューに反映させる。
        textView.text = dictionaryButtonAndString[sender]
        configueViewTapButtonStyle(Colors.mainColor, button: sender)
        //　一つのボタンが押された際、そのボタン以外は未選択状態にする。
        buttons.forEach { (button: UIButton) in
            button.isSelected = (button === sender)
            guard button.isSelected else {
                configueViewTapButtonStyle(Colors.baseColor, button: button)
                return
            }
        }
    }

    @IBAction private func decide(_ sender: Any) {
        // fimItemCountの位置を十分に考慮せずに配置。
        // 選択状態であるボタンを、フィルタリングして、一つだけ取り出す。（一つしか選択状態でないから、firstを使用）
        guard let button = buttons.filter({ $0.isSelected == true }).first else {
            // UIAlertControllerの起動
            present(alertController, animated: true, completion: nil)
            return
        }
        guard let num = dictionaryButtonAndNum[button] else { return }
        //　結果の配列に選択されたボタンと関連した数字を加える。
        assessmentResultFIM.append(num)
        fimItemCount += 1

        if fimItemCount == 18 {
            fim = FIM(
                eating: assessmentResultFIM[0],
                grooming: assessmentResultFIM[1],
                bathing: assessmentResultFIM[2],
                dressingUpperBody: assessmentResultFIM[3],
                dressingLowerBody: assessmentResultFIM[4],
                toileting: assessmentResultFIM[5],
                bladderManagement: assessmentResultFIM[6],
                bowelManagement: assessmentResultFIM[7],
                transfersBedChairWheelchair: assessmentResultFIM[8],
                transfersToilet: assessmentResultFIM[9],
                transfersBathShower: assessmentResultFIM[10],
                walkWheelchair: assessmentResultFIM[11],
                stairs: assessmentResultFIM[12],
                comprehension: assessmentResultFIM[13],
                expression: assessmentResultFIM[14],
                socialInteraction: assessmentResultFIM[15],
                problemSolving: assessmentResultFIM[16],
                memory: assessmentResultFIM[17],
                createdAt: Date()
            )
            guard let targetPersonUUID = targetPersonUUID else {
                fatalError("targetPersonUUIDの中身がない。メソッド名：[\(#function)]")
            }
            guard let fim = fim else {
                fatalError("FIMの中身がない。メソッド名：[\(#function)]")
            }
            fimRepository.appendFIM(targetPersonUUID: targetPersonUUID, fim: fim)

            toDetailFIMViewController(fim: fim)
        } else {
            updateScreenAndAllUIButtonIsSelectedFalse()
            configueViewButtonsStyle()
        }
    }

    @IBAction private func updateAttentionTextView(_ sender: Any) {
        buttons.forEach { (button: UIButton) in
            button.isSelected = false
        }
        textView.text = fimScoringCriteria[fimItemCount].attention
        configueViewButtonsStyle()
    }

    private func updateScreenAndAllUIButtonIsSelectedFalse() {
        buttons.forEach { (button: UIButton) in
            button.isSelected = false
        }
        updateLabelAndProgressView()
    }

    private func updateLabelAndProgressView() {
        progressTextLabel.text = "\(fimItemCount + 1)/18"
        fimItemTitleLabel.text = fimScoringCriteria[fimItemCount].fimItem
        textView.text = fimScoringCriteria[fimItemCount].attention
        let progressFloat = Float(fimItemCount + 1) / 18
        progressView.setProgress(progressFloat, animated: true)
    }
    // MARK: - Segue AssessmentViewController　→　DetailFIMViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController else { return }
        if let detailFIMVC = nav.topViewController as? DetailFIMViewController {
            switch segue.identifier ?? "" {
            case "detailFIM":
                detailFIMVC.fimUUID = fim?.uuid
                // このmodeによって、画面遷移先の次の画面遷移先を決めている。
                detailFIMVC.mode = .assessment
            default:
                break
            }
        }
    }
    // MARK: - Method
       private func toDetailFIMViewController(fim: FIM?) {
           let storyboard = UIStoryboard(name: "DetailFIM", bundle: nil)
           let nextVC =
           storyboard.instantiateViewController(withIdentifier: "detailFIM") as! DetailFIMViewController
           nextVC.fimUUID = fim?.uuid
           nextVC.mode = .assessment
           navigationController?.pushViewController(nextVC, animated: true)
       }
    // MARK: - UIAlert
    private let alertController: UIAlertController =
    UIAlertController(
        title: "未選択",
        message: "いずれかのボタンを選択してから、\n決定ボタンを押してください",
        preferredStyle: .alert
    )

    // UIAlertのOKボタンのaction
    private let defaultAction: UIAlertAction =
    UIAlertAction(
        title: "OK",
        style: .default
    )
    // MARK: - JSONファイルのデコーダー
    ///　FIMの採点基準
    struct FimScoringCriteria: Decodable {
        var fimItem: String
        var seven: String
        var six: String
        var five: String
        var four: String
        var three: String
        var two: String
        var one: String
        var attention: String
    }

    private func decodeFimJsonFile() {
        let data: Data?
        guard let file = Bundle.main.url(forResource: "FIM", withExtension: "json") else {
            fatalError("ファイルが見つかりません。メソッド名：[\(#function)]")
        }
        do {
            data  = try Data(contentsOf: file)
        } catch {
            fatalError("ファイルをロード不可。メソッド名：[\(#function)]")
        }

        do {
            guard let data = data else {
                fatalError("dataの中身が入っていない。メソッド名：[\(#function)]")
            }
            let decoder = JSONDecoder()
            fimScoringCriteria = try decoder.decode([FimScoringCriteria].self, from: data)
        } catch {
            fatalError("パース不可。メソッド名：[\(#function)]")
        }
    }
    // MARK: - View Configue
    private func configueViewProgressViewStyle() {
        progressView.progressTintColor = Colors.mainColor
    }

    private func configueViewButtonsStyle() {
        // 選択ボタンのView
        buttons.forEach {
            $0.backgroundColor = Colors.baseColor
            $0.setTitleColor(Colors.mainColor, for: .normal)
            $0.layer.cornerRadius = 25
            $0.layer.borderWidth = 2
            $0.layer.borderColor = Colors.mainColor.cgColor
            $0.layer.shadowOpacity = 0.5
            $0.layer.shadowRadius = 2
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 1, height: 1)
        }
        // 決定ボタンのView
        decisionButton.backgroundColor = Colors.baseColor
        decisionButton.setTitleColor(Colors.mainColor, for: .normal)
        decisionButton.layer.cornerRadius = 10
        decisionButton.layer.borderWidth = 2
        decisionButton.layer.borderColor = Colors.mainColor.cgColor
        decisionButton.layer.shadowOpacity = 0.7
        decisionButton.layer.shadowRadius = 3
        decisionButton.layer.shadowColor = Colors.mainColor.cgColor
        decisionButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        decisionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        attentionButton.tintColor = Colors.complementaryColor
    }

    // タップされた時の、選択ボタンのアニメーション
    private func configueViewTapButtonStyle(
        _ color: UIColor,
        button: UIButton
    ) {
        UIView.animate(withDuration: 0.5, delay: 0,
                       options: [.transitionCrossDissolve],
                       animations: {
            [weak self] in
            button.backgroundColor = color
            button.setTitleColor(Colors.baseColor, for: .selected)
        },
                       completion: nil)
    }
}
