# 世界の人の集計（world stats）

「今日、この雑学を世界で ○ 人・○ か国の人が見ています」を出す機能。Teen/Adult が、設定で**オンにしたときだけ**使う。Kids/Junior は通信しない。サーバー（`WORLD_STATS_URL`）が設定されていないビルドでは、この機能は出ない。

## プライバシー（守ること）
- 送るのは `fact`（雑学の id）・`region`（国コード。取れたときだけ）・`day`（日付）だけ。端末 ID・広告 ID・IP から作った ID・アカウントは送らない／保存しない。
- 初期はオフ。詳細画面の案内で、本人が「参加する」を選んだときだけオンになる。設定でいつでもオフにできる。
- 人数が少ないうちは出さない（アプリ側は 5 人未満なら出さない `worldMinShown`）。サーバー側も、国別の人数は 5 未満の国を `top` に含めない。
- 同じ日に同じ雑学は、端末から 1 回だけ送る。サーバー側でも、レート制限（IP ごと）と、入力の検証（`fact` は小文字英数字と _、`region` は大文字2文字、`day` は今日の前後1日）を行う。
- 保存する期間を決める（例: 日別の集計だけを 90 日）。個別の送信ログは長く残さない。
- ストアのプライバシー表示（データの収集）と、アプリ内のプライバシー画面（`privacyPointTeenAdult`）を、実際の動作に合わせる。

## API
ベース URL は `--dart-define=WORLD_STATS_URL=https://example.com/world`（https のみ）。

### POST `/v1/view`
```json
{"fact": "octopus_blue_blood", "region": "JP", "day": "2026-10-24"}
```
`region` は null でもよい。応答は 204（本文なし）。失敗してもアプリは何もしない。

### GET `/v1/today?fact=octopus_blue_blood&day=2026-10-24`
```json
{"total": 1234, "countries": 41, "top": [{"code": "JP", "count": 400}, {"code": "US", "count": 210}]}
```
`top` は多い順の最大 5 件。タイムアウトは 4 秒。200 以外・タイムアウトのときは、画面に出さない。

## 実装の目安
- Cloud Functions + Firestore のカウンター（`day/fact/region` 単位のインクリメント）、または Cloudflare Workers + KV/D1 など。どちらも匿名の集計だけで足りる。
- アプリ側: `lib/services/world_stats.dart`（`WorldStatsService`）、詳細画面のカード `_WorldCard`、設定のスイッチ。テストでは `worldStatsServiceProvider` を差し替える。
