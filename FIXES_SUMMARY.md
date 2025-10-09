# 修正完了サマリー

## 修正内容

### 1. テーブルビュー更新時のクラッシュ修正 ✅

**問題:**
```
Invalid batch updates detected: the number of sections and/or rows returned by the data source
before and after performing the batch updates are inconsistent with the updates.
```

**原因:**
- `reloadSections`を使用した部分更新で、行数の計算が不整合になっていた
- アコーディオンの展開/折りたたみ時に動的に行数が変わるため

**修正:**
```swift
// 修正前
tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)

// 修正後
tableView.reloadData()
```

**修正箇所:**
- `didSelectRowAt` (375行目) - 対象者の展開/折りたたみ
- `headerTapped` (426行目) - 評価者の展開/折りたたみ

---

### 2. UI配色を白基調に変更（ダークモード対応） ✅

**変更内容:**

#### 評価者ヘッダー
```swift
// 修正前
headerView.backgroundColor = UIColor(named: "navigation") ?? .systemBlue
label.textColor = .white
arrowLabel.textColor = .white
addButton.tintColor = .white
editButton.tintColor = .white

// 修正後
headerView.backgroundColor = .systemBackground
label.textColor = .label
arrowLabel.textColor = .label
addButton.tintColor = .systemBlue
editButton.tintColor = .systemBlue
```

#### 対象者セル
```swift
// 修正前
cell.backgroundColor = UIColor.systemGray5

// 修正後
cell.backgroundColor = .secondarySystemBackground
```

#### テーブルビュー
```swift
table.backgroundColor = .systemGroupedBackground
```

**ダークモード対応:**
- `.systemBackground` → 自動的にライト/ダークで白/黒に切り替わる
- `.label` → 自動的にライト/ダークで黒/白に切り替わる
- `.secondarySystemBackground` → グレーの背景（ダークモード対応）
- `.systemGroupedBackground` → グループ化テーブルの背景（ダークモード対応）

#### 階層ごとの配色

| レベル | 背景色 | テキスト色 | ボタン色 |
|--------|--------|-----------|----------|
| 評価者 | systemBackground | label | systemBlue |
| 対象者 | secondarySystemBackground | label | systemBlue |
| 評価項目 | systemBackground | label | systemBlue |

---

### 3. 重複名チェック機能を追加 ✅

**評価者の重複チェック:**
```swift
// 新規追加時
if existingAssessors.contains(where: { $0.name == name }) {
    self.showDuplicateAlert(type: "評価者")
    return
}

// 編集時（自分以外に同じ名前があるかチェック）
if existingAssessors.contains(where: {
    $0.uuidString != editingAssessor.uuidString && $0.name == name
}) {
    self.showDuplicateAlert(type: "評価者")
    return
}
```

**対象者の重複チェック:**
```swift
// 同じ評価者の中で重複チェック
let existingTargetPersons = self.timerAssessmentRepository.loadTargetPerson(assessor: assessor)

// 新規追加時
if existingTargetPersons.contains(where: { $0.name == name }) {
    self.showDuplicateAlert(type: "対象者")
    return
}

// 編集時
if existingTargetPersons.contains(where: {
    $0.uuidString != editingTargetPerson.uuidString && $0.name == name
}) {
    self.showDuplicateAlert(type: "対象者")
    return
}
```

**評価項目の重複チェック:**
```swift
// 同じ対象者の中で重複チェック
let existingAssessmentItems = self.timerAssessmentRepository.loadAssessmentItem(targetPerson: targetPerson)

// プリセット項目追加時
if existingAssessmentItems.contains(where: { $0.name == item }) {
    self.showDuplicateAlert(type: "評価項目")
    return
}

// カスタム項目追加時
if existingAssessmentItems.contains(where: { $0.name == name }) {
    self.showDuplicateAlert(type: "評価項目")
    return
}
```

**重複アラート表示:**
```swift
private func showDuplicateAlert(type: String) {
    let alert = UIAlertController(
        title: "重複エラー",
        message: "同じ名前の\(type)が既に存在します。\n別の名前を入力してください。",
        preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
}
```

**チェック対象:**
- ✅ 評価者の追加・編集
- ✅ 対象者の追加・編集
- ✅ 評価項目の追加（プリセット＆カスタム）

**スコープ:**
- 評価者: 全体で重複チェック
- 対象者: 同じ評価者内で重複チェック
- 評価項目: 同じ対象者内で重複チェック

---

### 4. 全画面対応の準備 ✅

**既に対応済みの画面:**

#### AccordionAssessorViewController
```swift
view.backgroundColor = .systemBackground
tableView.backgroundColor = .systemGroupedBackground
```

#### FunctionSelectionViewController
```swift
view.backgroundColor = .systemBackground
```

#### AssessmentViewController
```swift
view.backgroundColor = .systemBackground
```

#### DetailAssessmentViewController
```swift
view.backgroundColor = .systemBackground
```

**全画面でダークモード対応済み:**
- システムカラー（`.systemBackground`, `.label`等）を使用
- 自動的にライトモード/ダークモードに対応
- カスタムカラーは使用していない

---

## テスト確認事項

### 1. クラッシュ修正の確認
- [ ] 評価者を展開/折りたたみしてもクラッシュしない
- [ ] 対象者を展開/折りたたみしてもクラッシュしない
- [ ] 複数の評価者を同時に展開/折りたたみしても正常

### 2. UI配色の確認
- [ ] ライトモードで白基調で表示される
- [ ] ダークモードで黒基調で表示される
- [ ] 文字が読みやすい（黒文字/白文字）
- [ ] ボタンの色が適切（systemBlue）

### 3. 重複チェックの確認
- [ ] 同じ名前の評価者を追加しようとするとエラー表示
- [ ] 同じ名前の対象者を追加しようとするとエラー表示
- [ ] 同じ名前の評価項目を追加しようとするとエラー表示
- [ ] 編集時も同様にチェックされる
- [ ] 自分自身は重複とみなされない（編集時）

### 4. ダークモード対応の確認
- [ ] 設定 → 外観 → ダークモードに切り替え
- [ ] すべての画面が正しく表示される
- [ ] 文字が見やすい
- [ ] 背景色が適切

---

## 修正ファイル

```
/workspace/TimerAssessment/Assessor/AccordionAssessorViewController.swift
├── テーブルビュー更新の修正（2箇所）
├── UI配色の変更（5箇所）
├── 重複チェック機能の追加（5箇所）
└── ヘルパーメソッドの追加（1箇所）
```

---

## 使用したシステムカラー

### 背景色
- `.systemBackground` - メイン背景（白/黒）
- `.secondarySystemBackground` - セカンダリ背景（薄いグレー/濃いグレー）
- `.systemGroupedBackground` - グループテーブル背景

### テキスト色
- `.label` - メインテキスト（黒/白）

### アクセント色
- `.systemBlue` - ボタン、リンク

**メリット:**
- 自動的にダークモード対応
- Appleのヒューマンインターフェイスガイドラインに準拠
- 将来のiOSバージョンでも適切に表示

---

## まとめ

### 完了した修正
1. ✅ テーブルビュー更新時のクラッシュを修正
2. ✅ UI配色を白基調に変更（ダークモード対応）
3. ✅ 重複名チェック機能を追加（評価者・対象者・評価項目）
4. ✅ 全画面でダークモード対応

### 改善点
- **安定性**: クラッシュ問題を解決
- **視認性**: 白基調で見やすく、文字は黒で読みやすい
- **ユーザビリティ**: 重複名を防止してデータの整合性を向上
- **アクセシビリティ**: ダークモード対応で目に優しい

---

**修正日**: 2025-10-08
**修正ファイル**: AccordionAssessorViewController.swift
**修正行数**: 約20箇所
