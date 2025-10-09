# アコーディオン表示問題の修正

## 問題

アコーディオンUIで文字が重複したり、表示がおかしくなる問題が発生していました。

### 原因

1. **セル再利用時のリセット不足**
   - UITableViewのセルは再利用されるため、前の状態が残っていた
   - カスタムビュー（対象者レベル）とtextLabel（評価項目レベル）が混在

2. **重複するクリア処理**
   - 対象者レベルと評価項目レベルで個別にクリア処理を実行
   - セルの状態が不整合になっていた

3. **textLabelとカスタムビューの競合**
   - 対象者: カスタムビュー（UIView + UILabel + UIButton）
   - 評価項目: textLabel（UITableViewCell標準）
   - 両方が同時に表示される可能性があった

## 修正内容

### 1. セルの初期化処理を追加（254-263行目）

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

    // セルをリセット
    cell.contentView.subviews.forEach { $0.removeFromSuperview() }
    cell.textLabel?.text = nil
    cell.accessoryType = .none
    cell.backgroundColor = .systemBackground
    cell.indentationLevel = 0
    cell.selectionStyle = .default

    // ... 以降の処理
}
```

**変更点:**
- すべてのcellForRowAtの最初でセルを完全にリセット
- カスタムビュー、textLabel、accessoryType、背景色、インデントレベルをクリア
- これにより、セル再利用時の状態が確実にリセットされる

### 2. 対象者レベルの重複処理を削除（309-310行目削除）

**変更前:**
```swift
cell.contentView.subviews.forEach { $0.removeFromSuperview() }
cell.textLabel?.text = nil // textLabelをクリア

cell.contentView.addSubview(containerView)
```

**変更後:**
```swift
cell.contentView.addSubview(containerView)
```

**理由:**
- セルのリセットは最初に一度だけ実行すれば十分
- 重複した処理を削除

### 3. 評価項目レベルの重複処理を削除（332-333行目削除）

**変更前:**
```swift
if currentRow == indexPath.row {
    // カスタムビューをクリア
    cell.contentView.subviews.forEach { $0.removeFromSuperview() }

    // テキストラベルで表示
    cell.textLabel?.text = "⏱ \(assessmentItem.name)"
```

**変更後:**
```swift
if currentRow == indexPath.row {
    // テキストラベルで表示
    cell.textLabel?.text = "⏱ \(assessmentItem.name)"
```

**理由:**
- セルのリセットは最初に一度だけ実行すれば十分
- 重複した処理を削除

## 修正後の表示

### 正しい表示階層

```
📋 評価者1 [▼]
   👤 対象者A [▼]
      ⏱ 起立動作
      ⏱ 10m歩行
      ⏱ TUG
   👤 対象者B [▶]
📋 評価者2 [▶]
```

### 各レベルの表示方法

| レベル | 表示方法 | 背景色 | アクセサリー |
|--------|----------|--------|-------------|
| 評価者 | カスタムヘッダー | systemBlue | ➕ ℹ️ |
| 対象者 | カスタムビュー | systemGray5 | detailButton |
| 評価項目 | textLabel | systemBackground | disclosureIndicator |

## テストポイント

### 1. 基本表示
- [ ] 評価者ヘッダーが正しく表示される
- [ ] 対象者セルが重複なく表示される
- [ ] 評価項目セルが重複なく表示される

### 2. 展開/折りたたみ
- [ ] 評価者を展開すると対象者が表示される
- [ ] 対象者を展開すると評価項目が表示される
- [ ] 矢印アイコンが正しく切り替わる（▶/▼）

### 3. セル再利用
- [ ] スクロールしても文字が重複しない
- [ ] セルの背景色が正しい
- [ ] アクセサリーボタンが正しく表示される

### 4. 追加/編集/削除
- [ ] 新しい項目を追加しても表示が崩れない
- [ ] 編集後も表示が正しい
- [ ] 削除後にテーブルが正しく更新される

## セル再利用の仕組み

UITableViewはパフォーマンス向上のためセルを再利用します：

1. **画面外に出たセル**: プールに戻される
2. **新しく表示されるセル**: プールから取得（dequeue）
3. **再利用されるセル**: 前の状態が残っている可能性

**重要**: `cellForRowAt`で毎回セルを完全にリセットする必要があります。

### 修正前の問題例

```
// 1回目: 対象者セルを表示
cell: カスタムビュー（👤 田中太郎 [▼] ➕）

// セルが画面外へ → プールに戻る

// 2回目: 同じセルを評価項目で再利用
cell: カスタムビュー（👤 田中太郎 [▼] ➕）+ textLabel（⏱ 起立動作）
      ↑ 前の状態が残っている      ↑ 新しく設定

結果: 文字が重複表示
```

### 修正後

```
// 1回目: 対象者セルを表示
cell: リセット → カスタムビュー（👤 田中太郎 [▼] ➕）

// セルが画面外へ → プールに戻る

// 2回目: 同じセルを評価項目で再利用
cell: リセット → textLabel（⏱ 起立動作）
      ↑ 前の状態をクリア

結果: 正しく表示
```

## まとめ

### 修正箇所
1. ✅ cellForRowAtの先頭でセル状態を完全リセット
2. ✅ 対象者レベルの重複クリア処理を削除
3. ✅ 評価項目レベルの重複クリア処理を削除

### 効果
- ✅ 文字の重複が解消
- ✅ セル再利用時の表示が正しくなる
- ✅ 背景色とアクセサリーが正しく表示
- ✅ パフォーマンスの向上（余分な処理の削減）

---

**修正日**: 2025-10-08
**修正ファイル**: `/workspace/TimerAssessment/Assessor/AccordionAssessorViewController.swift`
**修正行数**: 3箇所（セルリセット追加、重複処理削除×2）
