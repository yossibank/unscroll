# 構成

> [!NOTE]
> 共通の形から外れた点と、ID など Unscroll だけの事実が分かる。共通の形は claude-config の `docs/app/ios-architecture.md` にある。

## 🖥️ 相棒の絵

相棒のドット絵は、DesignSystem の資源に置く。絵はスクリプトで描き、手で直さない。決め方は [相棒の決定](decisions/companion.md) にある。

| 置き場所 | 中身 |
| --- | --- |
| `scripts/companion-art.py` | 相棒の絵を描くスクリプト。種と毛の色ごとに 9 枚の 32×32 px の PNG を書く |
| `ios/Packages/UnscrollApp/Sources/DesignSystem/Resources/Companions.xcassets` | 描いた絵。名前は `<種>_<色>_<動き>` にする |

絵の名前の種と色は、次のとおりである。

| 種 | 色 |
| --- | --- |
| `shiba` | `red`・`black`・`white`・`sesame` |
| `tanuki` | `brown`・`dark`・`gray`・`white` |
| `penguin` | `gray`・`black`・`emperor`・`king` |

絵を描き直す時は、次のコマンドを走らせる。種を省くと、すべての種を描く。

```sh
python3 -I scripts/companion-art.py ios/Packages/UnscrollApp/Sources/DesignSystem/Resources/Companions.xcassets
```

## 🪟 Screen Time の拡張

ウィジェットの代わりに、Screen Time の拡張を持つ。試作の段階なので、中身はパッケージに分けず各フォルダに書く。

| フォルダ | ターゲット | Bundle ID | 役割 | App Group |
| --- | --- | --- | --- | --- |
| `ios/UnscrollMonitor/` | `UnscrollMonitorExtension` | `com.yossibank.unscroll.monitor` | 旅の終わりに止めたアプリを戻す（15 分より短い旅は、終わる前の知らせで戻す）。1 分開いたアプリを止め直す | 使う |
| `ios/UnscrollReport/` | `UnscrollReportExtension` | `com.yossibank.unscroll.report` | 今日の使用時間を描く。数字はアプリに渡らない | |
| `ios/UnscrollShield/` | `UnscrollShieldExtension` | `com.yossibank.unscroll.shield` | 止めたアプリを開いた時の画面の文字と色。押した時刻を読み、下のボタンの文字を替える | 使う |
| `ios/UnscrollShieldAction/` | `UnscrollShieldActionExtension` | `com.yossibank.unscroll.shieldaction` | 止めた画面のボタンで、10 秒の待ちと 1 分開くを決める | 使う |

アプリと拡張が共有する名前・記録・止め方は、Core の `ScreenTime/` にある。止め方は Screen Time の API を使うので、iOS だけで組む。

## 🔧 権限と署名

Family Controls の権限を、アプリと 4 つの拡張に付けている。

| 項目 | 状態 |
| --- | --- |
| 開発 | 開発の署名で実機に入れる |
| 配布 | Apple への申請と承認が要る。未申請 |
| 確かめる機体 | 実機だけ |

実機（開発の署名）で、次のことを確かめた。

| 確かめたこと | 結果 |
| --- | --- |
| 申請なしに許可を取る | ✅ 取れた |
| 選んだアプリを止め、止めた画面を出す | ✅ 出た |
| 止めた画面のボタンの拡張から、App Group に書く | ✅ 書けた |
| 使用時間の区切りが届き、見張りの拡張から App Group に書く | ✅ 書けた |
| 集中の時間が来ると、見張りの拡張が止めを外す | ✅ 外れた |
| 今日の使用時間を、使用時間の拡張が描く | ✅ 出た |
| 止めた画面の拡張から、App Group の値と DB を読む | ✅ 読めた |
| 止めた画面のボタンを押した後に、止めた画面を描き直す | ✅ 描き直した |
| 1 分開いた後に、見張りの終わる前の知らせで止め直す | ✅ 約 1 分で止め直した |
| 見張りを途中で止めると、終わりの知らせが届く | ✅ 届いた |

> [!WARNING]
> - シミュレーターで許可と見張りが動くかは、確かめていない
> - 止めた画面のボタンは、Unscroll を開けない。`.close` で止めたアプリを閉じ、ホーム画面に戻る
> - 区切りは、選んだアプリを使った時間で数える。止めた画面が出ている間は数えない
> - 記録は、アプリと拡張が同時に書くと 1 行が消えることがある。拡張が動かなかったと決める前に、記録の抜けを疑う
