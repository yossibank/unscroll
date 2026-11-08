# 構成

> [!NOTE]
> 共通の形から外れた点と、ID など Unscroll だけの事実が分かる。共通の形は claude-config の `docs/architecture-ios.md` にある。

## 🪟 Screen Time の拡張

ウィジェットの代わりに、Screen Time の拡張を持つ。試作の段階なので、中身はパッケージに分けず各フォルダに書く。

| フォルダ | ターゲット | Bundle ID | 役割 | App Group |
| --- | --- | --- | --- | --- |
| `ios/UnscrollMonitor/` | `UnscrollMonitorExtension` | `com.yossibank.unscroll.monitor` | 見張りの始まり・終わり・区切りを記録に書く。集中の終わりに止めたアプリを戻す | 使う |
| `ios/UnscrollReport/` | `UnscrollReportExtension` | `com.yossibank.unscroll.report` | 今日の使用時間を描く。数字はアプリに渡らない | |
| `ios/UnscrollShield/` | `UnscrollShieldExtension` | `com.yossibank.unscroll.shield` | 止めたアプリを開いた時の画面の文字と色 | |
| `ios/UnscrollShieldAction/` | `UnscrollShieldActionExtension` | `com.yossibank.unscroll.shieldaction` | 止めた画面のボタンを記録に書く | 使う |

アプリと拡張が共有する名前と記録は、Core の `ScreenTime/` にある。

## 🔧 権限と署名

Family Controls の権限を、アプリと 4 つの拡張に付けている。

| 項目 | 状態 |
| --- | --- |
| 開発 | 開発の署名で実機に入れる |
| 配布 | Apple への申請と承認が要る。未申請 |
| 確かめる機体 | 実機だけ |

> [!WARNING]
> 次のことは、まだ実機で確かめていない。
>
> - シミュレーターでは、許可と見張りが動かない
> - 見張りの拡張と止めた画面の拡張から、App Group に書ける
> - 開発の署名だけで、申請なしに許可を取れる
>
> 記録は、アプリと拡張が同時に書くと 1 行が消えることがある。拡張が動かなかったと決める前に、記録の抜けを疑う。
