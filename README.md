# fitlog_notes

A new Flutter project.

## Flutter

### パッケージ更新

`pubspec.yaml` 更新後 `flutter pub get`

## CLAUDE

### アップデート方法

基本は自動で更新される 手動で更新する場合は

```sh
claude update
```

https://docs.anthropic.com/en/docs/claude-code/setup#update-claude-code

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

## Git

### 機密データの削除

```sh
brew install git-filter-repo
mkdir -p ~/tmp && cd ~/tmp/ && git clone git@github.com:inoy/fitlog_notes.git && cd fitlog_notes
git-filter-repo --sensitive-data-removal --invert-paths --path PATH-TO-YOUR-FILE-WITH-SENSITIVE-DATA
git push --force --mirror origin
```

https://docs.github.com/ja/enterprise-cloud@latest/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository

もとのローカルリポジトリは以下でresetすればOK

```sh
git reset --hard origin/main
```

> You have divergent branches and need to specify how to reconcile them.

が表示されるため

## Note

### macOSで通知

`osascript -e 'display notification "message" with title "title" subtitle "subtitle" sound name "Breeze"'`
