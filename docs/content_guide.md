# 雑学データの管理ガイド

雑学は `assets/trivia/trivia.json` で管理する。ルールは `test/content_test.dart` と `test/content_validation_test.dart` が自動で確認する（守られていないとテストが失敗する）。

## 1件の雑学の項目

| 項目 | 意味 |
|---|---|
| `id` | 英小文字・数字・`_`。一度決めたら変えない（保存・評価・通知が参照する） |
| `status` | `active`=表示 / `hidden`=一時的に非表示 / `retired`=削除済み。**誤りが見つかったら、まず `hidden` にする** |
| `version` / `createdAt` / `updatedAt` | 本文を直したら `version` を上げ、`updatedAt` を更新する |
| `category` / `scenes` | ジャンル・利用シーン（絞り込み・関心事に使う） |
| `minAgeBand` | その年代以上に出す（`kids` / `junior` / `teen` / `adult`） |
| `sensitivity` | `none` / `mild`（Teen 以上）/ `adult-only`（Adult のみ） |
| `contentFlags` | 話題の種類のタグ（下記）。**該当するものを必ず付ける**。なければ空 |
| `regions` | **表示してよい国**（ISO 2文字、例 `["JP"]`）。空なら世界中 |
| `excludeRegions` | 表示しない国 |
| `seasons` | 季節（`spring` `summer` `autumn` `winter`。**北半球の季節で書く**。南半球は自動で反転） |
| `timeOfDay` | `morning` `day` `evening` `night` |
| `dates` | 記念日（`MM-DD`）。その日は「今日の雑学」になり、前後1日は「いまのおすすめ」に出る |
| `keywords` | 検索用の別名（読み・漢字・英語・類義語）。2個以上 |
| `related` | 関連する雑学のID（詳細画面の「関連する雑学」） |
| `sources` | 出典（`title` / `url` / `publisher` / `license` / `accessedAt`） |
| `verification` | 事実の検証（`status` / `verifiedBy` / `verifiedAt` / `note`） |
| `volatility` / `reviewDueAt` | `changing`（数字や記録が変わりうる）は見直し期限を入れる |
| `translations.<言語>` | `reviewStatus` / `reviewedBy` / `reviewedAt` / `levels`（年代別の本文） |

## 公開までの流れ

1. **draft**: 作成直後。デバッグビルドでは表示されるが、**リリースビルドでは配信されない**。
2. 事実確認: `sources` に一次情報を1件以上入れ、`verification` を `verified`（検証者・検証日つき）にする。
3. ネイティブ話者のレビュー: 各言語の `reviewStatus` を `reviewed`、`reviewedBy` / `reviewedAt` を入れる。
4. 上の記録がないまま `reviewed` / `published` にすると、テストが失敗する。

## 話題のタグ（`contentFlags`）と年代ごとの扱い

`sexual`（性）/ `violence`（暴力）/ `war`（戦争・兵器）/ `death`（死・被害）/ `religion`（宗教）/ `politics`（政治）/ `drugs_alcohol`（酒・たばこ・薬物）/ `gambling`（賭け事）/ `horror`（怖い）/ `discrimination`（差別）/ `crime`（犯罪）/ `medical`（医療）

- **Kids / Junior**: タグが1つでもあれば出さない。さらにテストが、文章・クイズに不適切なことば（殺・死・戦争・宗教・性・酒・賭け事など）が含まれていないか確認する。
- **Teen**: 性・暴力・酒たばこ薬物・賭け事・怖い・差別を出さない。
- **Adult**: 性的な話題のみ出さない。

## 国限定の雑学

`regions` に国を入れる（例: 日本の新幹線 → `["JP"]`）。**国が一致するときだけ**表示する。国は、設定の「国・地域」（既定は端末の地域。日本語の端末で地域が不明なら日本）で決まる。「すべての国」を選ぶと制限を使わない。

## 年代ごとの書き方

- **Kids（就学前）**: ひらがなのみ。単語の間は半角スペース（分かち書き）。1〜2文で短く。
- **Junior（小学生）**: 漢字を使ってよいが、**漢字のあとに必ず全角かっこで読みを添える**（例: `血（ち）`、`青（あお）い`）。小学校で習わない漢字は、ひらがなのまま。読み上げでは読みを除く。
- **Teen / Adult**: 通常の表記。Adult は、より詳しく正確に。

## 変更するとき

- 本文を直す → `version` を上げる、`updatedAt` を更新、再レビューが必要なら `reviewStatus` を `draft` に戻す。
- 誤りが見つかった → `status` を `hidden` にして、アプリを更新する。
- `changing` の雑学は、`reviewDueAt` までに数字・記録を確認し直す。


## データファイル一覧

| ファイル | 内容 |
|---|---|
| `trivia.json` | 雑学本体（年代別の本文、国・季節・時間帯・記念日、検索キーワード、関連、語彙 `vocab`） |
| `quiz.json` | Kids/Junior の○×クイズ（雑学ごとに1問） |
| `why_chains.json` | 「なぜ？」チェーン（ある雑学から次の雑学へつなぐ質問。1つの雑学から1本。ぐるぐる回らない） |
| `myths.json` | ほんと？うそ？（よくある勘違い）。子ども向け（ひらがな）と一般向けの2種類の文章 |
| `calendar.json` | 今日は何の日（国際デー・国の行事）。国限定は `regions` で管理 |
| `projects.json` | 自由研究ネタ帳。日本語は `{漢字|よみ}` の記法（Junior は「漢字（よみ）」、Teen/Adult は漢字のみに自動で直す） |

どのファイルも、`status` / `version` / `sources` / `verification` / 各言語の `reviewStatus` を持ち、**出典と検証の記録がないものは `reviewed` にできない**（テストで強制）。

## 語彙（`vocab`）の書き方

- `en`: 英語（英字とスペースだけ）。`ja`: 日本語の読み（ひらがな・カタカナだけ）。`kanji`: 漢字の表記（なければ空）。
- Teen/Adult には「たこ（蛸）」のように漢字も添え、Kids/Junior はかなだけを出す。1つの雑学に2〜4語。

## 自由研究（`projects.json`）を書くとき

- 材料・手順（3つ以上）・観察のポイント・**安全上の注意（必須）**を、日本語と英語で書く。
- 刃物・熱・あなあけ・風船など、危険なものを使うテーマは `needsAdult: true` にする（テストが危険なことばを検出して確認する）。
- 日本語の漢字は必ず `{漢字|よみ}`（読みはひらがな）で書く。記法の外に漢字を書くとテストが失敗する。
