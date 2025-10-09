# 過去評価画面の複数選択機能完了サマリー

## 完了した改善

### 1. ✅ 保存後の遷移先を過去評価一覧画面に変更

**変更前:**
```
保存ボタン
  ↓
「保存されました」アラート
  ├→ 「続けて記録」
  ├→ 「測定結果を見る」→ 測定結果詳細画面（1件のみ）
  └→ 「戻る」
```

**変更後:**
```
保存ボタン
  ↓
「保存されました」アラート
  ├→ 「続けて記録」
  ├→ 「過去評価を見る」→ 過去評価一覧画面（全データ）
  └→ 「戻る」
```

**実装:**
```swift
// 過去評価を見る
alert.addAction(UIAlertAction(
    title: "過去評価を見る",
    style: .default,
    handler: { [weak self] _ in
        self?.toPastAssessmentViewController()
    }
))

private func toPastAssessmentViewController() {
    let storyboard = UIStoryboard(name: "PastAssessment", bundle: nil)
    guard let nextVC = storyboard.instantiateViewController(withIdentifier: "pastAssessment") as? PastAssessmentViewController else {
        return
    }
    nextVC.assessmentItem = assessmentItem
    navigationController?.pushViewController(nextVC, animated: true)
}
```

**メリット:**
- ✅ 1件だけでなく全データを確認できる
- ✅ 他のデータと比較しやすい
- ✅ より多くの情報を表示

---

### 2. ✅ 過去評価画面に複数選択機能を追加

#### ナビゲーションバーの切り替え

**通常モード:**
```
[戻る]  対象者: 田中太郎 様  [🔄][選択]
```

**編集モード:**
```
[キャンセル]  対象者: 田中太郎 様  [📤][📋]
```

#### 実装

```swift
// 複数選択モード
private var isEditingMode = false
private var selectedIndexPaths: Set<IndexPath> = []

private func updateNavigationBar() {
    if isEditingMode {
        // 編集モード時
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "キャンセル",
            style: .plain,
            target: self,
            action: #selector(cancelEditMode)
        )

        // 右側: 共有とコピーボタン
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareSelectedItems)
        )
        let copyButton = UIBarButtonItem(
            image: UIImage(systemName: "doc.on.doc"),
            style: .plain,
            target: self,
            action: #selector(copySelectedItems)
        )
        navigationItem.rightBarButtonItems = [shareButton, copyButton]
    } else {
        // 通常モード時
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "戻る",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )

        // 右側: ソートと選択ボタン
        let sortButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down.circle"),
            style: .plain,
            target: self,
            action: #selector(showSortMenu)
        )
        let selectButton = UIBarButtonItem(
            title: "選択",
            style: .plain,
            target: self,
            action: #selector(enterEditMode)
        )
        navigationItem.rightBarButtonItems = [sortButton, selectButton]
    }
}
```

#### 編集モードの切り替え

```swift
@objc private func enterEditMode() {
    isEditingMode = true
    selectedIndexPaths.removeAll()
    tableView.allowsMultipleSelection = true
    updateNavigationBar()
    tableView.reloadData()
}

@objc private func cancelEditMode() {
    isEditingMode = false
    selectedIndexPaths.removeAll()
    tableView.allowsMultipleSelection = false
    updateNavigationBar()
    tableView.reloadData()
}
```

#### セルの選択処理

```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    if isEditingMode {
        // 編集モード: 選択/解除をトグル
        if selectedIndexPaths.contains(indexPath) {
            selectedIndexPaths.remove(indexPath)
        } else {
            selectedIndexPaths.insert(indexPath)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

// 編集モード時の選択表示
if isEditingMode {
    if selectedIndexPaths.contains(indexPath) {
        cell.accessoryType = .checkmark
    } else {
        cell.accessoryType = .none
    }
}
```

---

### 3. ✅ 複数選択したデータを共有・一括コピー

#### 共有機能

```swift
@objc private func shareSelectedItems() {
    guard !selectedIndexPaths.isEmpty else {
        showAlert(title: "選択してください", message: "共有するデータを選択してください。")
        return
    }

    let selectedData = getSelectedTimerAssessments()
    let textToShare = formatTimerAssessmentsForSharing(selectedData)

    let activityVC = UIActivityViewController(
        activityItems: [textToShare],
        applicationActivities: nil
    )

    // iPadのためのpopover設定
    if let popoverController = activityVC.popoverPresentationController {
        popoverController.barButtonItem = navigationItem.rightBarButtonItems?.first
    }

    present(activityVC, animated: true)
}
```

#### 一括コピー機能

```swift
@objc private func copySelectedItems() {
    guard !selectedIndexPaths.isEmpty else {
        showAlert(title: "選択してください", message: "コピーするデータを選択してください。")
        return
    }

    let selectedData = getSelectedTimerAssessments()
    let textToCopy = formatTimerAssessmentsForSharing(selectedData)

    UIPasteboard.general.string = textToCopy

    showAlert(title: "コピー完了", message: "\(selectedData.count)件のデータをコピーしました。")
}
```

#### データの取得

```swift
private func getSelectedTimerAssessments() -> [TimerAssessment] {
    let sortedIndexPaths = selectedIndexPaths.sorted { $0.row < $1.row }
    let allData = loadSortedTimerAssessments()
    return sortedIndexPaths.compactMap { indexPath in
        guard indexPath.row < allData.count else { return nil }
        return allData[indexPath.row]
    }
}
```

#### フォーマット処理

```swift
private func formatTimerAssessmentsForSharing(_ assessments: [TimerAssessment]) -> String {
    guard let assessmentItem = assessmentItem,
          let targetPerson = targetPerson else {
        return ""
    }

    var text = "【\(assessmentItem.name)】\n"
    text += "対象者: \(targetPerson.name)\n\n"

    for (index, assessment) in assessments.enumerated() {
        let resultString = resultTimerStringFormatter(resultTimer: assessment.resultTimer)
        let dateString: String
        if let createdAt = assessment.createdAt {
            dateString = createdAtdateFormatter(date: createdAt)
        } else {
            dateString = "--"
        }
        text += "\(index + 1). \(resultString) (\(dateString))\n"
    }

    return text
}
```

**出力例:**
```
【10m歩行】
対象者: 田中太郎

1. 00:12:34 (2025-10-08 10:30:00)
2. 00:11:45 (2025-10-08 11:00:00)
3. 00:13:12 (2025-10-08 14:30:00)
```

---

### 4. ✅ セルにコピーボタンと共有ボタンを追加

#### セルの実装

**PastAssessmentTableViewCell.swift:**
```swift
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

@IBAction private func copyAssessmentResult(_ sender: Any) {
    copyAssessmentTextHandler()
}

@IBAction private func shareAssessmentResult(_ sender: Any) {
    shareAssessmentTextHandler()
}

func configure(
    timerResultNumLabelString: String,
    createdAtLabelString: String,
    copyAssessmentTextHandler: @escaping() -> Void,
    shareAssessmentTextHandler: @escaping() -> Void
) {
    timerResultNumLabel.text = timerResultNumLabelString
    createdAtLabel.text = createdAtLabelString
    self.copyAssessmentTextHandler = copyAssessmentTextHandler
    self.shareAssessmentTextHandler = shareAssessmentTextHandler
}
```

#### ViewControllerでの設定

```swift
cell.configure(
    timerResultNumLabelString: resultTimerStringFormatter(resultTimer: timerAssessment.resultTimer),
    createdAtLabelString: createdAtString,
    copyAssessmentTextHandler: {[weak self] in
        UIPasteboard.general.string =
        CopyAndPasteFunctionAssessment(timerAssessment: timerAssessment).copyAndPasteString
        self?.copyButtonPushAlert(title: "コピー完了", message: "データ内容のコピーが\n完了しました。")
    },
    shareAssessmentTextHandler: {[weak self] in
        self?.shareAssessment(timerAssessment)
    }
)
```

#### 共有処理

```swift
private func shareAssessment(_ assessment: TimerAssessment) {
    let textToShare = CopyAndPasteFunctionAssessment(timerAssessment: assessment).copyAndPasteString

    let activityVC = UIActivityViewController(
        activityItems: [textToShare],
        applicationActivities: nil
    )

    // iPadのためのpopover設定
    if let popoverController = activityVC.popoverPresentationController {
        popoverController.sourceView = view
        popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        popoverController.permittedArrowDirections = []
    }

    present(activityVC, animated: true)
}
```

**セルのレイアウト:**
```
┌─────────────────────────────────────┐
│ 00:12:34                            │
│ 2025-10-08 10:30:00                 │
│                       [📋][📤]      │
└─────────────────────────────────────┘
```

---

## UIの最終形

### 通常モード

**ナビゲーションバー:**
```
[戻る]  対象者: 田中太郎 様  [🔄][選択]
```

**テーブルセル:**
```
┌─────────────────────────────────────┐
│ 00:12:34                            │
│ 2025-10-08 10:30:00                 │
│                       [📋][📤]      │
├─────────────────────────────────────┤
│ 00:11:45                            │
│ 2025-10-08 11:00:00                 │
│                       [📋][📤]      │
└─────────────────────────────────────┘
```

### 編集モード（複数選択）

**ナビゲーションバー:**
```
[キャンセル]  対象者: 田中太郎 様  [📤][📋]
```

**テーブルセル:**
```
┌─────────────────────────────────────┐
│ 00:12:34                          ✓ │
│ 2025-10-08 10:30:00                 │
│                       [📋][📤]      │
├─────────────────────────────────────┤
│ 00:11:45                            │
│ 2025-10-08 11:00:00                 │
│                       [📋][📤]      │
├─────────────────────────────────────┤
│ 00:13:12                          ✓ │
│ 2025-10-08 14:30:00                 │
│                       [📋][📤]      │
└─────────────────────────────────────┘
```

---

## ユーザーフロー

### フロー1: 単一データの共有

```
過去評価画面
  ↓ セルの📤ボタンタップ
共有シート表示
  ↓ 共有先選択（LINE、メール等）
共有完了
```

### フロー2: 複数データの共有

```
過去評価画面
  ↓ 「選択」ボタンタップ
編集モード
  ↓ データを複数選択（✓マーク）
  ↓ 右上の📤ボタンタップ
共有シート表示（全選択データ）
  ↓ 共有先選択
共有完了
  ↓ 「キャンセル」で通常モードへ
```

### フロー3: 複数データのコピー

```
過去評価画面
  ↓ 「選択」ボタンタップ
編集モード
  ↓ データを複数選択（✓マーク）
  ↓ 右上の📋ボタンタップ
「コピー完了: 3件のデータをコピーしました」
  ↓ クリップボードに保存
  ↓ 他のアプリで貼り付け可能
```

### フロー4: 測定後すぐに過去データと比較

```
測定画面
  ↓ Start → Stop → 保存
「保存されました: 00:12:34」
  ↓ 「過去評価を見る」
過去評価一覧画面
  ↓ 全データを確認・比較
  ↓ 必要に応じて共有
```

---

## 機能比較

| 機能 | Before | After |
|------|--------|-------|
| 保存後の遷移 | 測定結果詳細（1件） | 過去評価一覧（全件） |
| 単一コピー | ✅ | ✅ |
| 単一共有 | ❌ | ✅ |
| 複数選択 | ❌ | ✅ |
| 複数コピー | ❌ | ✅ |
| 複数共有 | ❌ | ✅ |
| データ比較 | 困難 | 容易 |

---

## ユースケース

### ケース1: 複数回測定したデータをまとめて共有

**シナリオ:** 10m歩行を3回測定し、理学療法士に報告

```
過去評価画面
  ↓ 「選択」
  ↓ 3件選択
  ↓ 📤共有
  ↓ LINEで送信
```

**共有されるテキスト:**
```
【10m歩行】
対象者: 田中太郎

1. 00:12:34 (2025-10-08 10:00:00)
2. 00:11:45 (2025-10-08 10:30:00)
3. 00:13:12 (2025-10-08 11:00:00)
```

### ケース2: ベストタイムだけを共有

**シナリオ:** 最速のタイムだけを共有したい

```
過去評価画面
  ↓ 🔄ソート → 「タイム: 速い順」
  ↓ 最速のセルの📤ボタン
  ↓ 共有シート
```

### ケース3: 月間データをExcelで分析

**シナリオ:** 1ヶ月分のデータをExcelに貼り付けて分析

```
過去評価画面
  ↓ 「選択」
  ↓ 月間データを全選択
  ↓ 📋コピー
  ↓ Excelを開く
  ↓ 貼り付け
  ↓ データ分析
```

### ケース4: 測定直後にデータ確認

**シナリオ:** 測定後すぐに過去データと比較

```
測定画面
  ↓ 保存
「保存されました」
  ↓ 「過去評価を見る」
過去評価一覧
  ↓ 過去のデータと比較
  ↓ 改善が見られる場合は共有
```

---

## UX改善ポイント

### 1. データの価値を最大化
**Before:** 1件ずつしか見れない
**After:** 全データを一覧で確認、複数選択可能

### 2. 共有のしやすさ
**Before:** コピーのみ、複数データは手動で集計
**After:** 複数データを一括で共有・コピー

### 3. ワークフローの改善
**Before:** 測定 → 詳細画面 → 戻る → 測定 → 詳細画面...
**After:** 測定 → 過去評価一覧 → 全データ確認・共有

### 4. データ比較の容易さ
**Before:** 1件ずつ表示、比較困難
**After:** 一覧表示、ソート機能で比較容易

### 5. 柔軟な共有
**Before:** コピーのみ
**After:** 共有シート（LINE、メール、AirDrop等）

---

## 技術的詳細

### 状態管理

```swift
// 複数選択モードの状態
private var isEditingMode: Bool
private var selectedIndexPaths: Set<IndexPath>

// モード切り替え
enterEditMode()  → isEditingMode = true
cancelEditMode() → isEditingMode = false
```

### データフロー

```
User: 「選択」タップ
       ↓
enterEditMode()
       ↓
isEditingMode = true
tableView.allowsMultipleSelection = true
updateNavigationBar()
       ↓
User: セルをタップ
       ↓
didSelectRowAt
       ↓
selectedIndexPaths に追加/削除
       ↓
セルにチェックマーク表示
       ↓
User: 共有ボタンタップ
       ↓
getSelectedTimerAssessments()
       ↓
formatTimerAssessmentsForSharing()
       ↓
UIActivityViewController 表示
```

---

## Before/After比較

### Before（改善前）

**保存後の遷移:**
- 測定結果詳細画面（1件のみ）
- 他のデータと比較困難

**共有機能:**
- セルごとにコピーボタンのみ
- 複数データの共有不可
- 手動で集計が必要

**データ確認:**
- 1件ずつ確認
- 全体像が把握しづらい

### After（改善後）

**保存後の遷移:**
- 過去評価一覧画面（全データ）
- 他のデータとの比較が容易

**共有機能:**
- セルごとにコピー＋共有ボタン
- 複数選択で一括共有・コピー
- フォーマット済みテキスト

**データ確認:**
- 全データ一覧表示
- ソート機能で整理
- 複数選択で分析

---

## テスト確認事項

### 保存後の遷移
- [x] 「過去評価を見る」→ 過去評価一覧画面へ遷移
- [x] 全データが表示される

### 複数選択機能
- [x] 「選択」ボタンで編集モードに切り替わる
- [x] セルタップで✓マークが表示される
- [x] 複数セルを選択できる
- [x] 「キャンセル」で通常モードに戻る

### 共有機能
- [x] 複数選択 → 共有ボタン → 共有シート表示
- [x] フォーマットされたテキストが共有される
- [x] セルの共有ボタンで単一データを共有

### コピー機能
- [x] 複数選択 → コピーボタン → クリップボードに保存
- [x] コピー完了アラート表示
- [x] セルのコピーボタンで単一データをコピー

### iPad対応
- [x] 共有シートがpopoverで表示される

---

## まとめ

### 完了した改善
1. ✅ 保存後の遷移を過去評価一覧画面に変更
2. ✅ 過去評価画面に複数選択機能を追加
3. ✅ 複数選択したデータを共有・一括コピー
4. ✅ セルにコピーボタンと共有ボタンを追加

### 技術的改善
- **状態管理**: isEditingMode で編集モードを管理
- **データ処理**: Set<IndexPath> で選択状態を効率管理
- **フォーマット**: 見やすいテキスト形式で出力

### UX改善
- **データ価値**: 1件 → 全件表示
- **共有方法**: コピーのみ → 共有シート対応
- **選択肢**: 単一 → 複数選択可能
- **ワークフロー**: より効率的な操作

### ユーザー体験
- より多くのデータを確認
- より簡単にデータ共有
- より柔軟なデータ活用
- より効率的な記録管理

---

**実装日**: 2025-10-08
**修正ファイル**:
- AssessmentViewController.swift
- PastAssessmentViewController.swift
- PastAssessmentTableViewCell.swift

**追加機能数**: 4つ（過去評価遷移、複数選択、共有、一括コピー）
