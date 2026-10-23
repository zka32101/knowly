# Knowly（雑学コレ！）

就学前から大人まで、世界中で楽しめる雑学アプリ（Flutter）。設計は [`docs/knowly_design_v2_global.md`](docs/knowly_design_v2_global.md)。

## できていること（v1.0 の土台）

- **年代モード**: Kids（就学前）/ Junior（小学生）/ Teen / Adult。生まれた年から年代を提案（若いほうに見積もる）。生まれた年は保存しない
- **Kids**: 1画面1雑学、大きな絵、端末内の読み上げ（`flutter_tts`）
- **Junior〜Adult**: 日替わりの雑学フィード（現地日付で決定。世界で同じ日に同じ雑学ではなく、各自の現地日付基準）
- **Teen/Adult**: 利用シーン・カテゴリーの絞り込み、コピー、保存、評価（へぇ/使える/スゴイ）
- **保護者ゲート**: 子どもモードからのモード変更・プレミアム案内の前に表示
- **多言語**: 日本語・英語（ARB）。端末の言語に追従、画面とコンテンツの言語は別々に変更可
- **コンテンツ**: 30件 × 4年代 × 日英（`assets/trivia/trivia.json`）
- **無料/プレミアムの枠**: Kids/Junior は全て無料。Teen/Adult は無料で7日分・保存20件まで
- **他アプリ紹介**（`cross_promo_kit` v0.3.0）: Teen/Adult の設定画面だけ。Kids/Junior では Firebase に接続しない

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
- applicationId は仮に `com.petitworks.knowly`。ストア登録前に確定する
