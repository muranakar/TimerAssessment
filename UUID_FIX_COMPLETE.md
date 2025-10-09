# UUID アンラップエラー修正完了

## 問題

データモデル（Assessor、TargetPerson、AssessmentItem）の`uuid`プロパティがcomputed propertyでオプショナル型：

```swift
struct Assessor {
    var uuidString = UUID().uuidString
    var name: String
    var uuid: UUID? {  // オプショナル型
        UUID(uuidString: uuidString)
    }
}
```

AccordionAssessorViewController.swiftで`uuid`を直接使用していたため、14箇所でコンパイルエラーが発生。

## 修正内容

すべての箇所で`guard let`または`if let`を使用してアンラップ：

### 1. numberOfRowsInSection (161, 172行目)
```swift
// 修正前
let isExpanded = expandedAssessors.contains(assessor.uuid)
if expandedTargetPersons.contains(targetPerson.uuid) {

// 修正後
guard let assessorUUID = assessor.uuid else { return 0 }
let isExpanded = expandedAssessors.contains(assessorUUID)
guard let targetPersonUUID = targetPerson.uuid else { continue }
if expandedTargetPersons.contains(targetPersonUUID) {
```

### 2. viewForHeaderInSection (186行目)
```swift
// 修正前
let isExpanded = expandedAssessors.contains(assessor.uuid)

// 修正後
guard let assessorUUID = assessor.uuid else { return nil }
let isExpanded = expandedAssessors.contains(assessorUUID)
```

### 3. cellForRowAt - 対象者レベル (267行目)
```swift
// 修正前
let isExpanded = expandedTargetPersons.contains(targetPerson.uuid)

// 修正後
guard let targetPersonUUID = targetPerson.uuid else { return cell }
let isExpanded = expandedTargetPersons.contains(targetPersonUUID)
```

### 4. cellForRowAt - 評価項目レベル (324行目)
```swift
// 修正前
if expandedTargetPersons.contains(targetPerson.uuid) {

// 修正後
if let targetPersonUUID = targetPerson.uuid, expandedTargetPersons.contains(targetPersonUUID) {
```

### 5. didSelectRowAt - 対象者タップ (358, 359, 361行目)
```swift
// 修正前
if expandedTargetPersons.contains(targetPerson.uuid) {
    expandedTargetPersons.remove(targetPerson.uuid)
} else {
    expandedTargetPersons.insert(targetPerson.uuid)
}

// 修正後
guard let targetPersonUUID = targetPerson.uuid else { return }
if expandedTargetPersons.contains(targetPersonUUID) {
    expandedTargetPersons.remove(targetPersonUUID)
} else {
    expandedTargetPersons.insert(targetPersonUUID)
}
```

### 6. didSelectRowAt - 評価項目タップ (369行目)
```swift
// 修正前
if expandedTargetPersons.contains(targetPerson.uuid) {

// 修正後
if let targetPersonUUID = targetPerson.uuid, expandedTargetPersons.contains(targetPersonUUID) {
```

### 7. headerTapped (406, 407, 410行目)
```swift
// 修正前
if expandedAssessors.contains(assessor.uuid) {
    expandedAssessors.remove(assessor.uuid)
} else {
    expandedAssessors.insert(assessor.uuid)
}

// 修正後
guard let assessorUUID = assessor.uuid else { return }
if expandedAssessors.contains(assessorUUID) {
    expandedAssessors.remove(assessorUUID)
} else {
    expandedAssessors.insert(assessorUUID)
}
```

### 8. addAssessmentItem (454行目)
```swift
// 修正前
if expandedTargetPersons.contains(targetPerson.uuid) {

// 修正後
if let targetPersonUUID = targetPerson.uuid, expandedTargetPersons.contains(targetPersonUUID) {
```

### 9. tableView commit editingStyle (578行目)
```swift
// 修正前
if expandedTargetPersons.contains(targetPerson.uuid) {

// 修正後
if let targetPersonUUID = targetPerson.uuid, expandedTargetPersons.contains(targetPersonUUID) {
```

## 修正パターン

### guard let パターン（早期リターンが必要な場合）
```swift
guard let uuid = object.uuid else { return }
// または
guard let uuid = object.uuid else { return nil }
// または
guard let uuid = object.uuid else { return 0 }
// または
guard let uuid = object.uuid else { continue }
```

### if let パターン（条件分岐の場合）
```swift
if let uuid = object.uuid, someCondition(uuid) {
    // 処理
}
```

## 修正箇所まとめ

| 行番号 | メソッド | 修正内容 |
|--------|----------|----------|
| 161 | numberOfRowsInSection | assessor.uuid → guard let |
| 172 | numberOfRowsInSection | targetPerson.uuid → guard let |
| 186 | viewForHeaderInSection | assessor.uuid → guard let |
| 267 | cellForRowAt | targetPerson.uuid → guard let |
| 324 | cellForRowAt | targetPerson.uuid → if let |
| 358-361 | didSelectRowAt | targetPerson.uuid → guard let (3箇所) |
| 369 | didSelectRowAt | targetPerson.uuid → if let |
| 406-410 | headerTapped | assessor.uuid → guard let (3箇所) |
| 454 | addAssessmentItem | targetPerson.uuid → if let |
| 578 | commit editingStyle | targetPerson.uuid → if let |

**合計**: 14箇所のエラーを修正

## ビルド確認

修正後、以下のコマンドでビルドを確認してください：

```bash
xcodebuild -project TimerAssessment.xcodeproj -scheme TimerAssessment -configuration Debug clean build
```

または、Xcodeで：
- ⌘B でビルド
- エラーがないことを確認

## 次のステップ

1. ✅ UUIDアンラップエラー修正完了
2. ⏳ Xcodeでビルド確認
3. ⏳ シミュレータ/実機で動作確認
4. ⏳ アコーディオンUIの全機能テスト

---

**修正日**: 2025-10-08
**修正ファイル**: `/workspace/TimerAssessment/Assessor/AccordionAssessorViewController.swift`
**修正箇所数**: 14箇所
