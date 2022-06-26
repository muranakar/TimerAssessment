//
//  FunctionSelectionViewController.swift
//  TimerAssessment
//
//  Created by 村中令 on 2022/02/01.
//

import UIKit

final class FunctionSelectionViewController: UIViewController {
    // 変数の受け皿
    var assessmentItem: AssessmentItem?
    let timerAssessmetRepository = TimerAssessmentRepository()
    @IBOutlet weak private var asssessmentButton: UIButton!
    @IBOutlet weak private var assessmentListButton: UIButton!
    @IBOutlet weak private var assessmentItemLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let targetPersonName = timerAssessmetRepository.loadTargetPerson(assessmentItem: assessmentItem!)?.name ?? ""
        let assessmentItemName = assessmentItem?.name ?? ""

        navigationItem.title = "対象者:\(targetPersonName)様"
        assessmentItemLabel.text = assessmentItemName
        configueViewNavigationBarColor()
        configueViewButtonStyle()
    }
    @IBAction private func shareTwitter(_ sender: Any) {
        shareOnTwitter()
    }
    @IBAction private func shareLine(_ sender: Any) {
        shareOnLine()
    }
    @IBAction private func shareOtherApp(_ sender: Any) {
        shareOnOtherApp()
    }

    @IBAction private func toAssessmentVC(_ sender: Any) {
        toAssessmentViewController(assessmentItem: assessmentItem!)
    }

    @IBAction private func toFIMTableVC(_ sender: Any) {
        toPastAssessmentViewController(assessmentItem: assessmentItem!)
    }

    // MARK: - Segue- FunctionSelectionViewController ← AssessmentViewController
    @IBAction private func backToFunctionSelectionTableViewController(segue: UIStoryboardSegue) {
    }
    // MARK: - Method
    private func toAssessmentViewController(assessmentItem: AssessmentItem) {
        let storyboard = UIStoryboard(name: "Assessment", bundle: nil)
        let nextVC =  storyboard.instantiateViewController(withIdentifier: "assessment") as! AssessmentViewController
        nextVC.assessmentItem = assessmentItem
        navigationController?.pushViewController(nextVC, animated: true)
    }

    private func toPastAssessmentViewController(assessmentItem: AssessmentItem) {
        let storyboard = UIStoryboard(name: "PastAssessment", bundle: nil)
        let nextVC =
        storyboard.instantiateViewController(withIdentifier: "pastAssessment") as! PastAssessmentViewController
        nextVC.assessmentItem = assessmentItem
        navigationController?.pushViewController(nextVC, animated: true)
    }
    private func shareOnTwitter() {
        // シェアするテキストを作成
        let text = "認知機能検査のHDS-Rを評価することが可能！"
        // swiftlint:disable:next line_length
        let hashTag = " #ADL #長谷川式 #認知機能 #病院 #クリニック #在宅 #医師 #理学療法士 #作業療法士 #言語聴覚士 #介護 #評価 #認知　#認知評価   \nhttps://apps.apple.com/jp/app/hds-r/id1616574755"
        let completedText = text + "\n" + hashTag

        // 作成したテキストをエンコード
        let encodedText = completedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        // エンコードしたテキストをURLに繋げ、URLを開いてツイート画面を表示させる
        if let encodedText = encodedText,
           let url = URL(string: "https://twitter.com/intent/tweet?text=\(encodedText)") {
            UIApplication.shared.open(url)
        }
    }

    private  func shareOnLine() {
        let urlscheme: String = "https://line.me/R/share?text="
        // swiftlint:disable:next line_length
        let message = "認知機能検査のHDS-Rを評価することが可能！ #ADL #長谷川式 #認知機能 #病院 #クリニック #在宅 #医師 #理学療法士 #作業療法士 #言語聴覚士 #介護 #評価 #認知　#認知評価   \nhttps://apps.apple.com/jp/app/hds-r/id1616574755"

        // line:/msg/text/(メッセージ)
        let urlstring = urlscheme + "/" + message

        // URLエンコード
        guard let  encodedURL =
                urlstring.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {
            return
        }

        // URL作成
        guard let url = URL(string: encodedURL) else {
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: { (succes) in
                    //  LINEアプリ表示成功
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // LINEアプリが無い場合
            let alertController = UIAlertController(title: "エラー",
                                                    message: "LINEがインストールされていません",
                                                    preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
            present(alertController,animated: true,completion: nil)
        }
    }

    private func shareOnOtherApp() {
        let url = URL(string: "https://sites.google.com/view/muranakar")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }


    // MARK: - View Configue
    private func configueViewNavigationBarColor() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "navigation")!
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }

    private func configueViewButtonStyle() {
        asssessmentButton.tintColor = Colors.baseColor
        asssessmentButton.backgroundColor = Colors.mainColor
        asssessmentButton.layer.cornerRadius = 10
        asssessmentButton.layer.shadowOpacity = 0.7
        asssessmentButton.layer.shadowRadius = 3
        asssessmentButton.layer.shadowColor = UIColor.black.cgColor
        asssessmentButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        assessmentListButton.tintColor = Colors.baseColor
        assessmentListButton.backgroundColor = Colors.mainColor
        assessmentListButton.layer.cornerRadius = 10
        assessmentListButton.layer.shadowOpacity = 0.7
        assessmentListButton.layer.shadowRadius = 3
        assessmentListButton.layer.shadowColor = UIColor.black.cgColor
        assessmentListButton.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
}
