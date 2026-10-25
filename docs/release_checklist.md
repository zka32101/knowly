# リリース前チェックリスト（サーバーなしで公開する場合）

世界の集計（`WORLD_STATS_URL`）は付けない。付けないビルドでは、その機能は画面に出ない。

## 0. 状況（2026-10-25 更新）
- 雑学 118 件のうち **115 件を `verified` / `reviewed`（5 言語）にした**（確認者は `owner`、日付 2026-10-25。オーナーの「すべて確認済み」の申告にもとづく）。公開ビルドに出る。
- **まだ `draft` のもの（公開ビルドには出ない）**:
  - 雑学 3 件（`sea_otters_hold_hands`、`ant_strong`、`eiffel_grows_summer`）: 出典がない。ルール上、出典なしでは reviewed にできない。出典を付けるか、本文を直す。
  - うわさ検証 20 件、今日は何の日 22 件、自由研究 12 件: 出典の記録がない。公開ビルドでは、これらの機能は空になる。出典を付けて reviewed にする（同じく、出典がないと reviewed にできない）。
- 母語話者によるレビューが済んでいない zh / ko / es も reviewed にしてある。実際にレビューしていないなら、`reviewStatus` を `draft` に戻すこと。

## 0'. （参考）未レビューの内容は、公開ビルドに出ない
- 雑学・クイズ・辞典・うわさ・カレンダー・自由研究・翻訳は、**すべて `draft`（未レビュー）**。公開ビルドは `draft` を出さないので、**そのままだと、雑学が1件も出ない**。
- 選択肢（どれかを決める）:
  1. **事実確認＋レビューを済ませてから出す（おすすめ）。** `docs/fact-check.md` / `fact-check.csv` で確認し、`verification.status: verified`、各言語の `reviewStatus: reviewed`（reviewedBy / reviewedAt）にする。まず ja / en の Kids・Junior を優先（子ども向けは人手で必須）。
  2. **確認できた分だけ出す。** 確認した雑学だけ `reviewed` にすれば、その分だけが出る（少なくてもよい）。
  3. **テスト配布だけ。** `--dart-define=ALLOW_DRAFT_CONTENT=true` で、内部テスト・クローズドテストに配る。ストアの一般公開には使わない。
- 母語話者レビューが済んでいない言語（zh / ko / es）は、その言語の雑学が出ず、英語に戻る（意図どおり）。

## 1. ビルド・署名
- [ ] 署名キーを作り、`android/key.properties` を用意（`docs/release_setup.md`）。キーストアは別にバックアップ。
- [ ] `flutter build appbundle --release --dart-define=REVENUECAT_ANDROID_KEY=... --dart-define=CONTACT_EMAIL=...`（`ALLOW_DRAFT_CONTENT` は付けない）
- [ ] iOS は Mac で `flutter build ios --no-codesign`（保留中）。

## 2. 課金
- [ ] ストアの商品: 月額 $1.99 / 年額 $14.99 / 7日トライアル。RevenueCat の Entitlement `premium`、Default offering に monthly / annual。
- [ ] 価格と文言は、各ストアで再確認（競合の価格は 2026-10 時点）。
- [ ] ペイウォールの法的な文言（自動更新・解約方法・トライアル終了後の課金）を確認。

## 3. 子ども向け規約・プライバシー
- [ ] Kids/Junior は通信しない・購入 SDK を呼ばない（テストで確認済み）。広告なし、`AD_ID` 権限なし。
- [ ] Google Play のデータセーフティ: 収集するデータは、購入情報（RevenueCat）と、Teen/Adult の他アプリ紹介（Firebase）。世界の集計は付けないので、申告しない。
- [ ] App Store のプライバシー栄養表示（同上）。子ども向けカテゴリーの要件（ガイドライン 1.3 / 5.1.4）を確認。
- [ ] プライバシーポリシーの公開 URL を用意（アプリ内のプライバシー画面と合わせる）。連絡先は `CONTACT_EMAIL`。
- [ ] 世界の集計の説明文（プライバシー画面）: サーバーを付けないので、現状は「オンにしたときだけ」の記述がある。付けないなら、記述が実際と合うか確認する。

## 4. ストア掲載
- [ ] 説明文・スクショ・動画: `docs/aso-rules.md`（yourwish リポジトリ）に従う。絵はいまは仮の絵文字なので、スクショの見栄えを確認。
- [ ] 年齢区分（レーティング）、対象年齢の申告（Kids/Junior を含む）。
- [ ] 各言語の掲載文（ja / en は必須。zh / ko / es は、レビューが済んでから）。

## 5. 最終確認
- [ ] 実機で: 初回起動 → 年代選択 → ホーム → 詳細 → クイズ → 保存 → 通知 → 設定（文字サイズ・ふりがな）→ プレミアム（サンドボックス購入・復元）。
- [ ] 機内モードで、同じ流れが動くこと（購入以外）。
- [ ] `flutter analyze` 指摘なし、`flutter test` 全通過。

## 6. 公開後
- RevenueCat のダッシュボードで、トライアル転換率・課金率を見る（アプリに分析は入れない）。3か月で、価格・無料範囲を見直す。
- 世界の集計を足すなら `docs/world-stats.md`（Cloudflare Workers など）。足すときは、プライバシーの表示も更新する。
