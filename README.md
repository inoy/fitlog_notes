# fitlog_notes

A new Flutter project.

## NEXT

次回再開時のプロンプト:

```
こんにちは。FitlogNotesプロジェクトの続きをお願いします。
GEMINI.mdにプロジェクトの概要と進め方を記載していますので、必要に応じて参照してください。

前回は「ステップ6：筋トレ記録の永続化（データの保存と読み込み）」を開始したところでした。
具体的には、`shared_preferences`パッケージを`pubspec.yaml`に追加する直前で中断しました。

次に何をしたいか教えてください。
（例: 「shared_preferencesパッケージの追加を続行してください」または「次のステップに進んでください」など）
```

## 検証

### 実機

`flutter run`

デバイスが複数登録されているならDevice IDを指定する `flutter run -d <device-id>`
Device IDの確認 `flutter devices`

### Simulator

`flutter run -d "iPhone 13 mini"`

シミュレータ起動: `open -a Simulator`

### ホットリロード

r or R押せば良い

```
Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
```
