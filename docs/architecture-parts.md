# 共通の部品の一覧

> [!NOTE]
> 複数の画面で使う仕組みの名前、使いどころ、置き場所が分かる。
> 共通の形は、claude-config の `docs/app/ios-screens.md` にある。

## 🪝 土台

画面とモデルをつなぐ型と関数である。新しい画面は、claude-config の `code-screen` のスキルで、この名前のまま足せる。

| 仕組み | 使いどころ | 置き場所 |
| --- | --- | --- |
| `ScreenParts` | DB と時計を包んで、画面からモデルへ渡す。中の DB は `FeatureModels` だけが読む | `FeatureModels/Shared/Model/` |
| `ScreenClock` | モデルの時計。テストでは `fixed` で止める | `FeatureModels/Shared/Model/` |

## 🪜 入れ物の作り方

`ScreenParts` は、次の関数で作る。画面と入口は、DB のモジュールを import しない。

| 仕組み | 使いどころ | 置き場所 |
| --- | --- | --- |
| `ScreenParts.appGroup(clock:)` | App Group の DB を同期で開いて作る。`RootView` が `AppModel` に渡す | `FeatureModels/Shared/Model/` |
| `ScreenParts.suspendDatabase()`・`resumeDatabase()` | アプリが裏に回る時に DB を止め、戻る時に再開する。`AppModel` が呼ぶ | `FeatureModels/Shared/Model/` |
| `launchCompanion()` | 起動の画面に出す相棒を読む。`AppModel` が呼ぶ | `FeatureModels/Shared/Model/` |

## 🧪 テストの部品

モデルのテストは、次の部品で `ScreenParts` と時計を作る。

| 仕組み | 使いどころ | 置き場所 |
| --- | --- | --- |
| `ScreenParts.system(_:)`・`fixed(_:at:)` | メモリの DB から、今の時刻か決まった時刻の入れ物を作る | `FeaturesTests/Support/` |
| `MovingClock` | テストの途中で時刻を進める時計 | `FeaturesTests/Support/` |
