# Knowly（雑学コレ！）

就学前から大人まで、世界中で楽しめる雑学アプリ（Flutter）。設計は [`docs/knowly_design_v2_global.md`](docs/knowly_design_v2_global.md)。

## できていること（v1.0 の土台）

- **年代モード**: Kids（就学前）/ Junior（小学生）/ Teen / Adult。生まれた年から年代を提案（若いほうに見積もる）。生まれた年は保存しない
- **Kids**: 1画面1雑学、大きな絵、端末内の読み上げ（`flutter_tts`）
- **Junior〜Adult**: 日替わりの雑学フィード（現地日付で決定。世界で同じ日に同じ雑学ではなく、各自の現地日付基準）
- **Teen/Adult**: 利用シーン・カテゴリーの絞り込み、コピー、保存、評価（へぇ/使える/スゴイ）
- **保護者ゲート**: 子どもモードからのモード変更・プレミアム案内の前に表示
- **多言語**: 日本語・英語（ARB）。端末の言語に追従、画面とコンテンツの言語は別々に変更可
- **コンテンツ**: 60件 × 4年代 × 日英（`assets/trivia/trivia.json`）。カテゴリーは動物・むし・のりもの・たべもの・宇宙・からだ・自然・科学・地理
- **子ども向けUI**: Kids は文字1.3倍・大きなボタン、Junior は1.15倍。Kids の設定は保護者ゲートの先
- **無料/プレミアムの枠**: Kids/Junior は全て無料。Teen/Adult は無料で7日分・保存20件まで
- **毎日の通知**: 端末内の予定通知（サーバー・通信なし）。先の14日ぶんを予定し、各日の通知は「その日の今日の雑学」と同じ。Teen/Adult は設定でオン、Junior は保護者ゲートの先、Kids はなし
- **他アプリ紹介**（`cross_promo_kit` v0.3.0）: Teen/Adult の設定画面だけ。Kids/Junior では Firebase に接続しない

## 検索・フィルター・関心事（Junior〜Adult）

- **ライブラリ**: 全雑学を一覧。検索（ひらがな/カタカナ/英字の大文字小文字を区別せず、日本語と英語のどちらのことばでも探せる）とフィルター（ジャンル・シーン・状態＝保存済み/知ってた/知らなかった/未評価）。無料の Teen/Adult は、無料の範囲外に鍵がつく（タップでプレミアム案内）
- **関心事の登録**: ジャンル・シーン・キーワード（最大10個）を登録すると、ホームに「あなたの関心」（日替わり。無料2件・プレミアム5件）が出る。端末内にだけ保存
- 一時的な絞り込み（ホームの「絞り込み」）と、関心事（登録して残る）は別。Kids は登録した「すきなもの」のジャンルだけが出る

## 競合との差別化機能

- **親子モード**: Teen/Adult の詳細画面で「こどもに説明するなら」→ 小学生向け / 就学前向けの説明に切り替え。同じ雑学の4年代版を持っているから実現できる
- **二言語表示**: 日本語と英語を並べて表示（Kids を除く）
- **「知ってた / 知らなかった」**: 端末内に保存し、設定に「知っていた雑学の割合」を表示
- **ストリーク（Teen/Adult のみ）**: 7日続くと「お休み券」がもらえ、1日休んでも途切れない。Kids/Junior は連続日数で煽らない（記録もしない）
- **○×クイズ（Kids/Junior）**: 読んだ雑学の復習用に52問。採点・ランキングなし

## 未実装（次にやること）

- 購入（RevenueCat）: `lib/services/entitlement.dart` を差し替える。商品・API キーの設定が必要
- Firebase（匿名認証・Firestore・FCM 通知）: 設定ファイル（`google-services.json` / `GoogleService-Info.plist`）が必要
- イラスト: 今は絵文字の仮表示。`lib/widgets/illustration.dart` を画像に差し替える
- シェアカード、オフライン保存、プレミアムの深掘り解説

## コンテンツの公開ルール

`assets/trivia/trivia.json` の各翻訳には `reviewStatus`（draft / reviewed / published）がある。
**リリースビルドでは draft を配信しない**（`kAllowDraftContent`）。ネイティブ話者・事実確認のレビューが済んだものを `reviewed` に変える。
デバッグビルドでは draft も表示される。

## 開発

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

`cross_promo_kit` は git 依存（プライベートリポジトリ）。取得できない環境では GitHub の認証を設定する。

## 設計上の判断メモ

- `app_common_kit` は使っていない。広告 SDK（`google_mobile_ads`）を依存に含み、子ども向けアプリの要件（広告 ID の権限なし）と衝突するため。保護者ゲートは `lib/widgets/parental_gate.dart` に同等のものを持つ
- applicationId / bundle ID は `com.yourwish.knowly`
