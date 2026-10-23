# リリース準備（ビルド・署名・課金）

## ビルド確認の結果
- Android: `flutter build apk --debug` / `flutter build appbundle --release` 成功（Flutter 3.47 / AGP・Gradle は Flutter 既定）。
- iOS: macOS が必要なため、このクラウド環境では未確認。Mac で `flutter build ios --no-codesign` を実行して確認する。
- 初回の Gradle は Maven Central の 429（レート制限）で失敗することがある。時間を置いて再実行すれば通る。

## Android 署名
1. `keytool -genkeypair -v -keystore ~/knowly-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. `android/key.properties`（git 管理外）を作る:
   ```
   storeFile=/絶対パス/knowly-upload.jks
   storePassword=...
   keyAlias=upload
   keyPassword=...
   ```
3. `flutter build appbundle --release --dart-define=REVENUECAT_ANDROID_KEY=... --dart-define=CONTACT_EMAIL=...`
- key.properties が無いとデバッグ署名になる（Play には出せない）。キーストアは紛失しないよう別途バックアップする。

## iOS
- Xcode で Signing & Capabilities を設定（Team、Bundle ID `com.yourwish.knowly`）。
- 「In-App Purchase」Capability を追加。通知は実機で確認。
- 子ども向け（Kids/Junior）カテゴリの扱いは App Store の審査ガイドライン 1.3 / 5.1.4 を確認。

## RevenueCat
- Entitlement ID: `premium`、Default offering に monthly / annual のパッケージ。
- キーは `--dart-define=REVENUECAT_IOS_KEY=...` / `REVENUECAT_ANDROID_KEY=...`（ソースに入れない）。
- ストア側の商品: 月額 $1.99、年額 $14.99、7日間トライアル。

## ビルド時の dart-define 一覧
| 名前 | 用途 |
|---|---|
| REVENUECAT_IOS_KEY / REVENUECAT_ANDROID_KEY | 課金 |
| CONTACT_EMAIL | プライバシー画面の連絡先 |
| APP_VERSION | 画面表示用バージョン |
| ALLOW_DRAFT_CONTENT | draft の雑学を出す（テスト用。リリースでは付けない） |
