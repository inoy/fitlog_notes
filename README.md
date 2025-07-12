# fitlog_notes

A new Flutter project.

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
