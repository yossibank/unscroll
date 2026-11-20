# 構成

> [!NOTE]
> 共通の形から外れた点と、ID などおるすマホだけの事実が分かる。共通の形は claude-config の `docs/app/ios-architecture.md` にある。

## 🖥️ ドット絵

相棒・名所・おみやげのドット絵は、DesignSystem の資源に置く。絵はスクリプトで描き、手で直さない。決め方は[相棒の決定](decisions/companion.md)と[名所の決定](decisions/landmark.md)にある。

資源は、すべて次のフォルダの下に置く。

- `ios/Packages/UnscrollApp/Sources/DesignSystem/Resources/`

| スクリプト | 描く絵 | 置き場所 | 名前 |
| --- | --- | --- | --- |
| `scripts/companion-art.py` | 相棒。種と毛の色ごとに 10 枚の 32×32 px | `Companions.xcassets` | `<種>_<色>_<動き>` |
| `scripts/landmark-art.py` | 名所の絵はがき。160×100 px | `Landmarks.xcassets` | `landmark_<名所>` |
| `scripts/souvenir-art.py` | おみやげの食べ物。48×48 px | `Souvenirs.xcassets` | `souvenir_<名所>` |
| `scripts/trip-art.py` | 旅の途中の景色。320×210 px の 3 層 | `Trips.xcassets` | `trip_<名所>_<層>` |
| `scripts/room-art.py` | 部屋の壁・床・家具を、180×140 px の別々の絵に描く。窓は透明 | `Rooms.xcassets` | `room_back`・`room_wall_<柄>`・`room_floor_<柄>` |
| `scripts/map-art.py` | 地図の土台。228×150 px | `Maps.xcassets` | `map_<道のり>` |

名所の英字の名前は `Landmark.artName`（`Landmark+Art.swift`）で決める。景色の層は `SceneryLayer` の `far`・`mid`・`near` である。相棒の絵の名前の種と色は、次のとおりである。

| 種 | 色 |
| --- | --- |
| `shiba` | `red`・`black`・`white`・`sesame` |
| `tanuki` | `brown`・`dark`・`gray`・`white` |
| `penguin` | `gray`・`black`・`emperor`・`king` |

名所・おみやげ・旅の景色・地図の描き方は、道のりごとに `scripts/journeys/<道のり>/` にある。ファイルは `landmark.py`・`souvenir.py`・`trip.py`・`map.py` である。共通の部品は `scripts/artlib/` にある。

スクリプトは `scripts/journeys/` の下の道のりをすべて読むので、道のりを足す時はフォルダを 1 つ足す。

`practice/` は道のりではなく、練習の旅で届く架空の名所の絵である。`landmark.py`・`souvenir.py`・`trip.py` を持ち、`map.py` は持たない。

絵を描き直す時は、次のコマンドを走らせる。種や名所を省くと、すべてを描く。出力先を `.xcassets` でないフォルダにすると、並べた見本も書く。

```sh
python3 -I scripts/companion-art.py ios/Packages/UnscrollApp/Sources/DesignSystem/Resources/Companions.xcassets
python3 -I scripts/landmark-art.py ios/Packages/UnscrollApp/Sources/DesignSystem/Resources/Landmarks.xcassets
python3 -I scripts/souvenir-art.py ios/Packages/UnscrollApp/Sources/DesignSystem/Resources/Souvenirs.xcassets
python3 -I scripts/trip-art.py ios/Packages/UnscrollApp/Sources/DesignSystem/Resources/Trips.xcassets
python3 -I scripts/room-art.py ios/Packages/UnscrollApp/Sources/DesignSystem/Resources/Rooms.xcassets
python3 -I scripts/map-art.py ios/Packages/UnscrollApp/Sources/DesignSystem/Resources/Maps.xcassets
```

部屋の絵の窓・紐・棚・座布団の位置は、`RoomScene.swift` の座標とそろえる。地図の経度と緯度の写し方は、2 つのファイルでそろえる。`JourneyMapGeometry+<道のり>.swift` と `scripts/journeys/<道のり>/map.py` である。

## 🪟 Screen Time の拡張

ウィジェットの代わりに、Screen Time の拡張を持つ。試作の段階なので、中身はパッケージに分けず各フォルダに書く。

| フォルダ | ターゲット | Bundle ID | 役割 | App Group |
| --- | --- | --- | --- | --- |
| `ios/UnscrollMonitor/` | `UnscrollMonitorExtension` | `com.yossibank.unscroll.monitor` | 旅の終わりに止めたアプリを戻す（15 分より短い旅は、終わる前の知らせで戻す）。1 分開いたアプリを止め直す | 使う |
| `ios/UnscrollReport/` | `UnscrollReportExtension` | `com.yossibank.unscroll.report` | 今日の使用時間を描く。数字はアプリに渡らず、色は DesignSystem から受け取る | |
| `ios/UnscrollShield/` | `UnscrollShieldExtension` | `com.yossibank.unscroll.shield` | 止めた画面に相棒の手紙を描く。DB は読むだけで開き、相棒の絵は DesignSystem から受け取る | 使う |
| `ios/UnscrollShieldAction/` | `UnscrollShieldActionExtension` | `com.yossibank.unscroll.shieldaction` | 止めた画面のボタンで、10 秒の待ちと 1 分開くを決める | 使う |

アプリと拡張が共有する名前・記録・止め方・外しにくさ・手紙の文は、Core の `ScreenTime/` にある。止め方は Screen Time の API を使うので、iOS だけで組む。

## 📂 ストアのファイル

App Store に出すものは、次の場所に置く。

| 場所 | 中身 |
| --- | --- |
| `store/ja/` | 日本語の掲載情報 |
| `store/screenshots/raw/` | 6.9 インチのシミュレーターで撮った元の画面 |
| `store/screenshots/6.9/` | ストアに出す画像 |
| `.claude/snapshots/store/` | `raw/` の画面に見出しを重ね、`6.9/` の画像を描く |
| `PrivacyInfo.xcprivacy` | アプリと 4 つの拡張のそれぞれに置く |
| unscroll-support | サポートとプライバシーポリシーのページ。別のリポジトリで、GitHub Pages で出す |

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
| 止めた画面の拡張から、App Group に書く | 🛑 書けない。記録も残らない |
| カテゴリで止めたアプリのボタンで、ボタンの拡張にアプリが渡る | 🛑 カテゴリだけが渡る |
| 止めた画面のボタンを押した後に、止めた画面を描き直す | ✅ 描き直した |
| 1 分開いた後に、見張りの終わる前の知らせで止め直す | ✅ 約 1 分で止め直した |
| 見張りを途中で止めると、終わりの知らせが届く | ✅ 届いた |

> [!WARNING]
> - シミュレーターで許可と見張りが動くかは、確かめていない
> - 止めた画面のボタンは、おるすマホを開けない。`.close` で止めたアプリを閉じ、ホーム画面に戻る
> - 区切りは、選んだアプリを使った時間で数える。止めた画面が出ている間は数えない
> - 記録は、アプリと拡張が同時に書くと 1 行が消えることがある。拡張が動かなかったと決める前に、記録の抜けを疑う
