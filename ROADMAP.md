# タイマー評価アプリ - ロードマップ

## アプリ概要

### 基本情報
- **アプリ名**: タイマー評価（TimerAssessment）
- **バージョン**: 1.2.0
- **プラットフォーム**: iOS 15.1+
- **主要技術**: Swift, RealmSwift, RevenueCat, RevenueCatUI
- **Bundle ID**: com.muranaka.TimerAssessment

### アプリの目的
医療・介護分野における機能評価（例：ADL評価、リハビリテーション評価）で、対象者の動作や活動にかかる時間を計測・記録するためのツール。評価者が複数の対象者・評価項目を管理し、タイマー機能で正確に測定できる。

---

## 現在の機能構成

### 1. データモデル（4層構造）

#### 階層構造
```
評価者（Assessor）
  └─ 対象者（TargetPerson）[複数]
      └─ 評価項目（AssessmentItem）[複数]
          └─ タイマー評価（TimerAssessment）[複数]
```

#### 各モデルの詳細

**Assessor（評価者）**
- `uuidString`: UUID文字列
- `name`: 評価者名
- 役割: 評価を実施する人（セラピスト、看護師など）

**TargetPerson（対象者）**
- `uuidString`: UUID文字列
- `name`: 対象者名
- 役割: 評価される人（患者、利用者など）

**AssessmentItem（評価項目）**
- `uuidString`: UUID文字列
- `name`: 評価項目名
- 役割: 測定する動作や活動（例：歩行、食事、更衣など）

**TimerAssessment（タイマー評価）**
- `uuidString`: UUID文字列
- `resultTimer`: Double（測定時間）
- `createdAt`: Date?（作成日時）
- `updatedAt`: Date?（更新日時）
- 役割: 実際の測定結果データ

### 2. 画面構成と機能

#### 2.1 評価者選択画面（AssessorViewController）
- **機能**:
  - 評価者の一覧表示
  - 評価者の追加・編集・削除
  - アコーディオン形式で対象者を表示
  - 対象者への直接遷移
- **UI特徴**:
  - アコーディオン展開/折りたたみ
  - スワイプで削除
  - 設定画面へのアクセス

#### 2.2 対象者選択画面（TargetPersonViewController）
- **機能**:
  - 特定の評価者に紐づく対象者一覧
  - 対象者の追加・編集・削除
  - 評価項目画面への遷移
- **UI特徴**:
  - TableView形式
  - スワイプで削除

#### 2.3 評価項目選択画面（AssessmentItemViewController）
- **機能**:
  - 特定の対象者に紐づく評価項目一覧
  - 評価項目の追加・編集・削除
  - 機能選択画面への遷移
- **UI特徴**:
  - TableView形式
  - スワイプで削除

#### 2.4 機能選択画面（FunctionSelectionViewController）
- **機能**:
  - 「評価開始」ボタン → タイマー測定画面へ
  - 「過去評価一覧」ボタン → 過去の測定データ一覧へ
  - 設定画面へのアクセス
- **表示情報**:
  - 対象者名
  - 評価項目名

#### 2.5 評価（タイマー測定）画面（AssessmentViewController）
- **機能**:
  - Start/Stop/Resetボタン
  - 高精度タイマー表示（分:秒:1/100秒）
  - DisplayLink使用による滑らかな表示更新
  - 保存機能（Saveボタン）
  - 未保存データ警告
  - 保存後の選択肢
    - 続けて記録
    - 過去評価を見る
    - 戻る
- **UI特徴**:
  - モダンなUIButton.Configuration使用
  - 大きなボタン（視認性重視）
  - カスタム戻るボタン（未保存データ確認）

#### 2.6 過去評価一覧画面（PastAssessmentViewController）
- **機能**:
  - 測定結果の一覧表示
  - ソート機能
    - 日付: 新しい順/古い順
    - タイム: 速い順/遅い順
  - 複数選択モード
    - 複数データの選択
    - 一括コピー
    - 一括共有
  - 個別データ操作
    - データのコピー
    - データの共有
    - スワイプで削除
- **表示形式**:
  - 測定時間（秒数または分秒表示）
  - 測定日時
  - カスタムセル（PastAssessmentTableViewCell）

#### 2.7 設定画面（SettingsViewController）
- **機能**:
  - アプリ共有
    - Twitter共有
    - LINE共有
    - その他のアプリで共有
  - サポート
    - アプリレビュー依頼
    - お問い合わせ（メール/Twitter）
- **UI特徴**:
  - TableView形式
  - セクション分け

### 3. データ永続化

#### Realm使用
- **RealmSwift**: データベース管理
- **Repository パターン**: TimerAssessmentRepository
- **CRUD操作**: 全モデルで実装済み
- **リレーション**: List と LinkingObjects による双方向関係
- **主キー**: uuidString

### 4. 既存の外部ライブラリ

#### RevenueCat & RevenueCatUI
- プロジェクトに追加済み（v5.43.0+）
- **現在未実装** - サブスクリプション機能の準備が整っている状態

---

## サブスクリプション化計画

### フェーズ1: 調査・仕様策定 【現在のフェーズ】
- [x] アプリの現状分析
- [x] 機能の洗い出し
- [x] ロードマップ作成
- [ ] 無料/プレミアム機能の分類
- [ ] 価格設定の検討

### フェーズ2: RevenueCat設定
- [ ] RevenueCatダッシュボードでProduct設定
- [ ] App Store Connectでサブスクリプション設定
- [ ] APIキー取得・設定

### フェーズ3: 実装
- [ ] RevenueCat初期化コード追加（AppDelegate）
- [ ] サブスクリプション状態管理クラス作成
- [ ] Paywall画面実装
- [ ] 機能制限ロジック実装
- [ ] レストア機能実装

### フェーズ4: テスト
- [ ] サンドボックステスト
- [ ] 各種エッジケースの確認
- [ ] 無料トライアルのテスト

### フェーズ5: リリース準備
- [ ] App Store審査用スクリーンショット
- [ ] プライバシーポリシー更新
- [ ] 利用規約作成
- [ ] マーケティング素材作成

---

## 技術的特徴

### 優れている点
1. **データ構造が明確**: 4層の階層構造で管理が容易
2. **Repositoryパターン**: データアクセスが統一されている
3. **高精度タイマー**: DisplayLinkによる正確な時間計測
4. **優れたUX**: アコーディオンUI、未保存データ警告など
5. **モダンなコード**: Swift modern features使用

### 改善の余地
1. エラーハンドリング（try!の多用）
2. 設定の永続化（ソート順の保存など）
3. データのエクスポート/バックアップ機能
4. 統計・グラフ機能
5. 多言語対応

---

## 次のステップ

### 即座に取り組むべきこと
1. **サブスクリプション仕様書の作成**
   - 無料機能とプレミアム機能の明確な線引き
   - 価格設定の検討
   - トライアル期間の設定

2. **収益化戦略の決定**
   - ターゲットユーザーの明確化
   - 競合調査
   - 価格帯の決定

3. **技術実装計画**
   - RevenueCat統合の詳細設計
   - 機能制限の実装方法

### 中長期的な展望
- データ同期機能（iCloud）
- iPad最適化
- Apple Watch対応
- CSV/PDFエクスポート
- 統計・分析機能
- テンプレート機能（評価項目セット）

---

## 付録

### ファイル構成
```
TimerAssessment/
├── AppDelegate.swift
├── Setting/
│   ├── SettingsViewController.swift
│   └── Settings.storyboard
├── Assessor/
│   ├── AssessorViewController.swift
│   ├── AccordionAssessorViewController.swift
│   ├── AssessorTableViewCell.swift
│   ├── Main.storyboard
│   └── ReviewRepository.swift
├── TargetPerson/
│   ├── TargetPersonViewController.swift
│   ├── TargetPersonTableViewCell.swift
│   └── TargetPerson.storyboard
├── AssessmentItem/
│   ├── AssessmentItemViewController.swift
│   ├── AssessmentItemTableViewCell.swift
│   └── AssessmentItem.storyboard
├── FunctionSelection/
│   ├── FunctionSelectionViewController.swift
│   └── FunctionSelection.storyboard
├── Assessment/
│   ├── AssessmentViewController.swift
│   └── Assessment.storyboard
├── PastAssessment/
│   ├── PastAssessmentViewController.swift
│   ├── PastAssessmentTableViewCell.swift
│   ├── PastAssessmentTableViewCell.xib
│   └── PastAssessment.storyboard
├── DetailAssessment/
│   ├── DetailAssessmentViewController.swift
│   └── DetailAssessment.storyboard
├── TimerAssessmentRepository/
│   ├── TimerAssessmentRepository.swift
│   ├── TimerAssessment.swift
│   └── SceneDelegate.swift
├── CopyAndPaste/
│   └── CopyAndPasteFunctionAssessment.swift
└── Color/
    └── Colors.swift
```

### 既存ドキュメント
- SCREEN_NAMING_GUIDE.md
- IMPROVEMENT_PROPOSAL.md
- IMPLEMENTATION_SUMMARY.md
- ACCORDION_INTEGRATION_COMPLETE.md
- UUID_FIX_COMPLETE.md
- ACCORDION_DISPLAY_FIX.md
- FIXES_SUMMARY.md
- ACCORDION_IMPROVEMENTS.md
- BUTTON_IMPROVEMENTS.md
- MODERN_UI_IMPROVEMENTS.md
- PAST_ASSESSMENT_IMPROVEMENTS.md
- ASSESSMENT_SCREEN_IMPROVEMENTS.md
- PAST_ASSESSMENT_MULTI_SELECT.md
- CELL_SPACING_REDUCTION.md

---

*最終更新: 2025年10月10日*
