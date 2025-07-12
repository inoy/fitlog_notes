# CLAUDE.md

このファイルは、このリポジトリでコードを操作する際のClaude Code (claude.ai/code) へのガイダンスを提供します。

## プロジェクト概要

FitlogNotesは、個人用の筋トレ記録を行うFlutter製iOSフィットネス追跡アプリケーションです。このプロジェクトは、各コード変更について明確な説明を伴うステップバイステップの実装を通じて、Flutterの学習に重点を置いています。

## 開発コマンド

### アプリの実行
```bash
flutter run                          # デフォルトデバイスで実行
flutter run -d <device-id>          # 特定のデバイスで実行
flutter run -d "iPhone 13 mini"     # iOSシミュレータで実行
flutter devices                     # 利用可能なデバイスを一覧表示
```

### コード品質
```bash
flutter analyze                     # 静的解析（analysis_options.yamlとflutter_lintsを使用）
```

### その他のコマンド
```bash
open -a Simulator                   # iOSシミュレータを起動
```

### ホットリロード
- `r`キーでホットリロード
- `R`キーでホットリスタート
- `h`キーでヘルプ
- `q`キーで終了

## アーキテクチャ

### コア構造
- **Models**: JSON シリアライゼーション機能付きデータクラス（`Exercise`、`WorkoutRecord`、`WorkoutDetail`、`WeeklyMenuItem`）
- **Repositories**: `shared_preferences`を使用したローカルストレージのデータ永続化レイヤー
- **Screens**: Flutterウィジェット分割ベストプラクティスに従ったUIコンポーネント

### 主要コンポーネント

#### データレイヤー
- `ExerciseRepository`: 事前定義データフォールバック機能付きエクササイズ定義管理
- `WorkoutRepository`: ワークアウト記録の永続化処理
- `WeeklyWorkoutMenuRepository`: 週間ワークアウトメニューアイテム管理
- すべてのリポジトリは`shared_preferences`を使用したJSONベースのローカルストレージを使用

#### モデル
- `Exercise`: デフォルト`WorkoutType`（回数/時間）付きワークアウトタイプ定義
- `WorkoutRecord`: エクササイズ参照と複数の詳細を含む個別ワークアウトセッション
- `WorkoutDetail`: 特定のワークアウト指標（値 + タイプ: 回数または秒）
- `WeeklyMenuItem`: 週間ワークアウト計画構造

## 開発方針

### ウィジェット分割のベストプラクティス

UIの複雑性を管理し、コードの可読性、再利用性、テスト容易性を向上させるため、以下の原則を適用します：

1. **単一責任の原則 (SRP) に基づく分割**
   - 一つのウィジェットは一つの明確な責任のみを持つ
   - `build`メソッドが複雑になったら新しいウィジェットとして切り出す

2. **UIとロジックの分離**
   - UI描画に特化したウィジェット（`StatelessWidget`）と状態管理ウィジェット（`StatefulWidget`）を明確に区別
   - 可能な限り`StatelessWidget`を使用

3. **小さなウィジェットの作成**
   - 深いネストを避け、各ウィジェットの`build`メソッドを簡潔に保つ
   - コードの変更を特定のウィジェットに限定し、副作用のリスクを削減

4. **明確なインターフェース**
   - コンストラクタ引数（`final`フィールド）やコールバック関数（`ValueChanged`など）を通じた明確なインターフェース定義
   - 一方向データフロー：親→子へデータ、子→親へイベント通知

### データの永続化
- 軽量なキーバリューストレージに`shared_preferences`を使用
- データはアプリセッション間で永続化されるが、アプリアンインストール時に消失
- すべてのモデルが`toJson()`/`fromJson()`でシリアライゼーション実装
- リポジトリがエンコード/デコードとフォールバックデータを処理

### ナビゲーション構造
- メイン画面：カレンダービューと日次ワークアウトフィルタリング機能付き`WorkoutListScreen`
- エクササイズ管理：ワークアウトタイプ定義用`ExerciseListScreen`
- 週間計画：ワークアウトスケジューリング用`WeeklyMenuScreen`
- 記録入力：ワークアウト記録作成/編集用`AddWorkoutScreen`

## 依存関係

主要パッケージ：
- `shared_preferences`: ローカルデータ永続化
- `table_calendar`: 日付選択カレンダーウィジェット
- `intl`: 日付フォーマットと国際化
- `uuid`: 一意識別子生成
- `flutter_lints`: コード品質とスタイル強制

## 開発ガイドライン

### 基本方針
- **学習目標**: このプロジェクトを通してFlutterを学習する
- **開発スタイル**: 一つ一つのステップごとに進め、各コード変更について明確な解説を行う
- **コミット方針**: ワンステップごとにコミットする
- **ドキュメント方針**: Flutter関連の技術的詳細や学習内容は`docs/`ディレクトリにまとめる

### 実装ルール
- 確立されたウィジェット分割パターンに従う
- UIテキストには日本語を使用（ターゲット：日本のユーザー）
- 機能追加時は既存のデータ構造との互換性を維持
- すべてのFlutter開発にウィジェット分割ベストプラクティスを適用し、コードベースの一貫性と品質を維持

### 実装済み機能
- Flutterプロジェクトの初期設定
- 筋トレ記録の追加、表示、永続化（`shared_preferences`による保存・読み込み）
- 筋トレ記録の編集・削除機能
- 筋トレ記録に日付を追加する機能（nullable対応済み）
- トップ画面にカレンダーと今日の記録表示（`table_calendar`導入済み）
- ウィジェット分割のベストプラクティス適用
- 筋トレ種目管理機能の基盤（`Exercise`モデル、`ExerciseRepository`、`ExerciseListScreen`）
- 週間筋トレメニュー管理機能の基盤（`WorkoutType`、`WorkoutDetail`、`WeeklyMenuItem`モデル、`WeeklyWorkoutMenuRepository`、`WeeklyMenuScreen`）
- 種目管理機能の拡張（`Exercise`モデルに`WorkoutType`を追加、`ExerciseListScreen`で`WorkoutType`の選択UIを実装）
- 筋トレ記録機能の更新（`WorkoutRecord`モデルを`List<WorkoutDetail>`に対応、`AddWorkoutScreen`と`WorkoutRecordItem`を更新）
- 週間メニュー追加画面の実装（`AddWeeklyMenuItemScreen`で種目、曜日、複数の`WorkoutDetail`の入力に対応）