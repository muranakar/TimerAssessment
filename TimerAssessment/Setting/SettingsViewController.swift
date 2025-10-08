//
//  SettingsViewController.swift
//  TimerAssessment
//
//  Created by Claude on 2025/10/08.
//

import UIKit
import StoreKit
import MessageUI

final class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    private enum Section: Int, CaseIterable {
        case share
        case support

        var title: String {
            switch self {
            case .share: return "共有"
            case .support: return "サポート"
            }
        }
    }

    private enum ShareRow: Int, CaseIterable {
        case twitter
        case line
        case other

        var title: String {
            switch self {
            case .twitter: return "Twitterで共有"
            case .line: return "LINEで共有"
            case .other: return "その他のアプリで共有"
            }
        }
    }

    private enum SupportRow: Int, CaseIterable {
        case review
        case contact

        var title: String {
            switch self {
            case .review: return "このアプリを応援する"
            case .contact: return "お問い合わせ"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "設定"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        configueViewColor()
    }

    @IBAction private func dismissSettings(_ sender: Any) {
        dismiss(animated: true)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        switch sectionType {
        case .share:
            return ShareRow.allCases.count
        case .support:
            return SupportRow.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section(rawValue: section)?.title
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 44 : 32
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator

        guard let sectionType = Section(rawValue: indexPath.section) else { return cell }

        switch sectionType {
        case .share:
            if let row = ShareRow(rawValue: indexPath.row) {
                cell.textLabel?.text = row.title
            }
        case .support:
            if let row = SupportRow(rawValue: indexPath.row) {
                cell.textLabel?.text = row.title
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let sectionType = Section(rawValue: indexPath.section) else { return }

        switch sectionType {
        case .share:
            handleShareAction(row: indexPath.row)
        case .support:
            handleSupportAction(row: indexPath.row)
        }
    }

    // MARK: - Share Actions
    private func handleShareAction(row: Int) {
        guard let shareRow = ShareRow(rawValue: row) else { return }

        let shareText = "タイマー評価アプリを使っています！ #タイマー評価"
        let appURL = URL(string: "https://apps.apple.com/app/id1234567890")! // 実際のApp IDに変更してください

        switch shareRow {
        case .twitter:
            shareToTwitter(text: shareText, url: appURL)
        case .line:
            shareToLine(text: shareText, url: appURL)
        case .other:
            shareToOtherApps(text: shareText, url: appURL)
        }
    }

    private func shareToTwitter(text: String, url: URL) {
        let twitterText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let twitterURL = URL(string: "twitter://post?message=\(twitterText)")
        let webTwitterURL = URL(string: "https://twitter.com/intent/tweet?text=\(twitterText)&url=\(url.absoluteString)")

        if let twitterURL = twitterURL, UIApplication.shared.canOpenURL(twitterURL) {
            UIApplication.shared.open(twitterURL)
        } else if let webTwitterURL = webTwitterURL {
            UIApplication.shared.open(webTwitterURL)
        }
    }

    private func shareToLine(text: String, url: URL) {
        let lineText = "\(text)\n\(url.absoluteString)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let lineURL = URL(string: "https://line.me/R/msg/text/?\(lineText)")

        if let lineURL = lineURL {
            UIApplication.shared.open(lineURL)
        }
    }

    private func shareToOtherApps(text: String, url: URL) {
        let items: [Any] = [text, url]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)

        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        present(activityVC, animated: true)
    }

    // MARK: - Support Actions
    private func handleSupportAction(row: Int) {
        guard let supportRow = SupportRow(rawValue: row) else { return }

        switch supportRow {
        case .review:
            requestReview()
        case .contact:
            showContactOptions()
        }
    }

    private func requestReview() {
        if let scene = view.window?.windowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private func showContactOptions() {
        let alert = UIAlertController(title: "お問い合わせ", message: "お問い合わせ方法を選択してください", preferredStyle: .actionSheet)

        // メールでお問い合わせ
        let emailAction = UIAlertAction(title: "メールで問い合わせ", style: .default) { [weak self] _ in
            self?.sendEmail()
        }
        alert.addAction(emailAction)

        // Twitterでお問い合わせ
        let twitterAction = UIAlertAction(title: "Twitterで問い合わせ", style: .default) { _ in
            if let url = URL(string: "https://twitter.com/KaradaHelp") {
                UIApplication.shared.open(url)
            }
        }
        alert.addAction(twitterAction)

        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        alert.addAction(cancelAction)

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }

    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@example.com"]) // 実際のメールアドレスに変更してください
            mail.setSubject("タイマー評価アプリについて")
            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "メール送信不可", message: "メールアカウントが設定されていません", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    // MARK: - View Configure
    private func configueViewColor() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "navigation")
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
}
