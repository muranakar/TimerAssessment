# 画面命名ガイド

このドキュメントは、TimerAssessmentアプリの各画面を指示する際の統一的な名称を定義します。

## 画面一覧と命名定義

### 1. 評価者画面（Assessor Screen）
- **日本語名**: 評価者画面
- **英語名**: Assessor Screen
- **短縮名**: 評価者
- **ファイル**:
  - `TimerAssessment/Assessor/AssessorViewController.swift`
  - `TimerAssessment/Assessor/Base.lproj/Main.storyboard`
- **説明**: アプリの最初の画面。評価者（医師、理学療法士など）の一覧を表示し、追加・編集・削除が可能
- **主な機能**:
  - 評価者の一覧表示
  - 評価者の追加（アラート入力）
  - 評価者の編集（アラート入力）
  - 評価者の削除（スワイプ削除）
  - 設定画面への遷移（歯車ボタン）

---

### 2. 対象者画面（Target Person Screen）
- **日本語名**: 対象者画面
- **英語名**: Target Person Screen
- **短縮名**: 対象者
- **ファイル**:
  - `TimerAssessment/TargetPerson/TargetPersonViewController.swift`
  - `TimerAssessment/TargetPerson/TargetPerson.storyboard`
- **説明**: 選択した評価者の対象者（患者）一覧を表示する画面
- **主な機能**:
  - 対象者の一覧表示
  - 対象者の追加（アラート入力）
  - 対象者の編集（アラート入力）
  - 対象者の削除（スワイプ削除）
  - 設定画面への遷移（歯車ボタン）
  - 戻るボタン

---

### 3. 評価項目画面（Assessment Item Screen）
- **日本語名**: 評価項目画面
- **英語名**: Assessment Item Screen
- **短縮名**: 評価項目
- **ファイル**:
  - `TimerAssessment/AssessmentItem/AssessmentItemViewController.swift`
  - `TimerAssessment/AssessmentItem/AssessmentItem.storyboard`
- **説明**: 選択した対象者の評価項目一覧を表示する画面
- **主な機能**:
  - 評価項目の一覧表示
  - 評価項目の追加（アクションシート → プリセット選択 or カスタム入力）
    - プリセット項目: 起立動作、10m歩行、片脚立位(右)、片脚立位(左)、TUG
  - 評価項目の編集（アラート入力）
  - 評価項目の削除（スワイプ削除）
  - 設定画面への遷移（歯車ボタン）
  - 戻るボタン

---

### 4. 機能選択画面（Function Selection Screen）
- **日本語名**: 機能選択画面
- **英語名**: Function Selection Screen
- **短縮名**: 機能選択
- **ファイル**:
  - `TimerAssessment/FunctionSelection/FunctionSelectionViewController.swift`
  - `TimerAssessment/FunctionSelection/FunctionSelection.storyboard`
- **説明**: 評価項目を選択後に表示される画面。タイマー計測と過去の記録閲覧を選択
- **主な機能**:
  - 「評価を開始」ボタン → タイマー計測画面へ遷移
  - 「評価一覧」ボタン → 過去の評価一覧画面へ遷移
  - Twitter共有ボタン
  - LINE共有ボタン
  - その他アプリ共有ボタン
  - レビュー依頼ボタン

---

### 5. タイマー計測画面（Assessment/Timer Screen）
- **日本語名**: タイマー計測画面
- **英語名**: Assessment Screen / Timer Screen
- **短縮名**: タイマー / 計測
- **ファイル**:
  - `TimerAssessment/Assessment/AssessmentViewController.swift`
  - `TimerAssessment/Assessment/Assessment.storyboard`
- **説明**: 実際にタイマーで計測を行う画面
- **主な機能**:
  - Startボタン（計測開始）
  - Stopボタン（計測停止）
  - Resetボタン（リセット）
  - 保存ボタン（ナビゲーションバー右上）→ 詳細画面へ遷移
  - タイマー表示（mm:ss:cc形式）

---

### 6. 評価詳細画面（Detail Assessment Screen）
- **日本語名**: 評価詳細画面
- **英語名**: Detail Assessment Screen
- **短縮名**: 詳細 / 結果詳細
- **ファイル**:
  - `TimerAssessment/DetailAssessment/DetailAssessmentViewController.swift`
  - `TimerAssessment/DetailAssessment/DetailAssessment.storyboard`
- **説明**: 計測完了後に表示される画面。計測結果の詳細を表示
- **主な機能**:
  - 対象者名の表示
  - 評価項目名の表示
  - 計測結果の表示
  - コピーボタン（計測データをクリップボードへコピー）

---

### 7. 過去の評価一覧画面（Past Assessment Screen）
- **日本語名**: 過去の評価一覧画面
- **英語名**: Past Assessment Screen
- **短縮名**: 評価一覧 / 履歴
- **ファイル**:
  - `TimerAssessment/PastAssessment/PastAssessmentViewController.swift`
  - `TimerAssessment/PastAssessment/PastAssessment.storyboard`
- **説明**: 選択した評価項目の過去の計測記録一覧を表示
- **主な機能**:
  - 過去の計測記録一覧表示（テーブルビュー）
  - 並び替えボタン（昇順・降順切り替え）
  - 各記録のコピーボタン
  - 記録の削除（スワイプ削除）
  - 計測日時の表示
  - 計測結果の表示

---

### 8. 設定画面（Settings Screen）
- **日本語名**: 設定画面
- **英語名**: Settings Screen
- **短縮名**: 設定
- **ファイル**:
  - `TimerAssessment/Setting/SettingsViewController.swift`
  - `TimerAssessment/Setting/Settings.storyboard`
- **説明**: アプリの設定と共有機能を提供する画面。全画面から歯車アイコンでアクセス可能
- **主な機能**:
  - **共有セクション**:
    - Twitterで共有
    - LINEで共有
    - その他のアプリで共有
  - **サポートセクション**:
    - このアプリを応援する（レビュー依頼）
    - お問い合わせ（メール・Twitter選択）
  - 閉じるボタン（モーダル表示のため）

---

## 画面遷移フロー

```
評価者画面
  ↓ （評価者選択）
対象者画面
  ↓ （対象者選択）
評価項目画面
  ↓ （評価項目選択）
機能選択画面
  ├→ タイマー計測画面
  │    ↓ （保存）
  │   評価詳細画面
  │
  └→ 過去の評価一覧画面

※ 全画面から設定画面へアクセス可能（歯車アイコン）
```

---

## 指示時の使用例

### 良い指示例
- ✅ "評価者画面のプラスボタンの色を変更してください"
- ✅ "タイマー計測画面のStartボタンを大きくしてください"
- ✅ "設定画面の共有セクションに新しい項目を追加してください"
- ✅ "評価項目画面のアクションシートのプリセットを変更してください"

### 避けるべき指示例
- ❌ "最初の画面" → 評価者画面と明示
- ❌ "リスト画面" → どのリスト画面か明示（評価者/対象者/評価項目/過去の評価一覧）
- ❌ "メイン画面" → 具体的な画面名を使用
- ❌ "計測画面" → タイマー計測画面 or 評価詳細画面か明示

---

## ファイル命名規則

### ViewControllerファイル
- パターン: `{機能名}ViewController.swift`
- 例: `AssessorViewController.swift`, `TargetPersonViewController.swift`

### Storyboardファイル
- パターン: `{機能名}.storyboard` または `Main.storyboard`（初期画面）
- 例: `AssessmentItem.storyboard`, `Settings.storyboard`

### TableViewCellファイル
- パターン: `{機能名}TableViewCell.swift`
- 例: `AssessorTableViewCell.swift`, `PastAssessmentTableViewCell.swift`

---

## 用語集

| 日本語 | 英語 | 説明 |
|--------|------|------|
| 評価者 | Assessor | 評価を行う医療従事者（医師、理学療法士など） |
| 対象者 | Target Person | 評価を受ける患者 |
| 評価項目 | Assessment Item | 評価する項目（起立動作、10m歩行など） |
| 計測 | Assessment / Measurement | タイマーでの時間計測 |
| 評価一覧 | Past Assessment / Assessment List | 過去の計測記録一覧 |
| 機能選択 | Function Selection | 計測開始と履歴閲覧の選択画面 |
| 設定 | Settings | アプリの設定と共有機能 |

---

## 更新履歴

- 2025-10-08: 初版作成
  - 全8画面の命名定義を作成
  - 画面遷移フローを追加
  - 指示例と用語集を追加
