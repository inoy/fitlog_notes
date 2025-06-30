# Flutter StatefulWidgetのライフサイクル (initStateとdispose)

このドキュメントは、Flutterの`StatefulWidget`における重要なライフサイクルメソッドである`initState`と`dispose`について解説します。

## StatefulWidgetとは？

`StatefulWidget`は、その状態（データ）が時間とともに変化する可能性のあるウィジェットです。例えば、ユーザーの入力によって表示が変わるテキストフィールドや、ボタンが押されるたびにカウンターが増えるようなウィジェットがこれに該当します。

`StatefulWidget`は、`State`オブジェクトと組み合わせて使用されます。`State`オブジェクトがウィジェットの「状態」を保持し、その状態が変更されるとウィジェットが再構築（リビルド）されます。

## 重要なライフサイクルメソッド

### 1. `initState()`

-   **いつ呼び出されるか:** `State`オブジェクトが初めて作成され、ウィジェットツリーに挿入される際に、**一度だけ**呼び出されます。
-   **何に使うか:**
    -   `State`オブジェクトの初期化を行います。
    -   `TextEditingController`のような、ウィジェットのライフサイクルに紐づくリソースの初期化に最適です。
    -   `super.initState()`を必ず最初に呼び出す必要があります。
-   **例 (`TextEditingController`の初期化):**
    ```dart
    class _MyScreenState extends State<MyScreen> {
      late TextEditingController _myController;

      @override
      void initState() {
        super.initState();
        _myController = TextEditingController(); // ここでコントローラーを初期化
        // 必要であれば、初期値を設定することも可能
        // _myController.text = "初期テキスト";
      }

      // ... buildメソッドなど
    }
    ```

### 2. `dispose()`

-   **いつ呼び出されるか:** `State`オブジェクトがウィジェットツリーから完全に削除され、破棄される直前に呼び出されます。これは、ウィジェットがもう画面に表示されなくなり、メモリから解放されることを意味します。
-   **何に使うか:**
    -   `initState`で初期化したリソース（`TextEditingController`、アニメーションコントローラー、ストリーム購読など）を解放し、メモリリークを防ぎます。
    -   リスナーの解除など、不要になったリソースをクリーンアップします。
    -   `super.dispose()`を必ず最後に呼び出す必要があります。
-   **例 (`TextEditingController`の破棄):**
    ```dart
    class _MyScreenState extends State<MyScreen> {
      // ... initStateメソッドなど

      @override
      void dispose() {
        _myController.dispose(); // ここでコントローラーを破棄し、リソースを解放
        super.dispose(); // 最後にsuper.dispose()を呼び出す
      }

      // ... buildメソッドなど
    }
    ```

## なぜ`initState`と`dispose`が重要なのか？

これらのメソッドを適切に使用することで、アプリケーションのパフォーマンスを最適化し、メモリリークを防ぐことができます。

-   **メモリリークの防止:** `TextEditingController`のようなオブジェクトは、内部的にリスナーや他のリソースを保持しています。`dispose`でこれらを明示的に解放しないと、ウィジェットが画面から消えてもこれらのリソースがメモリに残り続け、アプリケーションの動作が遅くなったり、クラッシュの原因となることがあります。
-   **リソースの効率的な管理:** 不要になったリソースを速やかに解放することで、アプリケーションが使用するメモリ量を減らし、全体的な効率を向上させます。

このドキュメントは、`/Users/inoy/git/fitlog_notes/docs/FLUTTER_LIFECYCLE.md` に保存されています。