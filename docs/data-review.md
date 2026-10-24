# データ構造レビュー（2026-10-23）

対象: `assets/trivia/*.json` と、それを読むモデル（`lib/models/`）。

## 現状
- 雑学82件 × 5言語（ja/en/zh/ko/es）× 4段階（kids/junior/teen/adult）。Teen/Adult のみの雑学が2件（chimborazo_farthest, human_dna_same）。
- ID の重複なし。`related` の参照先はすべて実在（テストで検証）。
- 未レビュー（draft）の翻訳は、公開ビルドでは出ない（`kAllowDraftContent`）。

## 問題点（優先順）
1. **公開ビルドで中身が空になる**: 全翻訳が `draft`、出典 `sources` も全82件が空。人の事実確認・出典付けが必要。
2. **ファイルごとにメタ情報がバラバラ**: trivia/myths/calendar/projects は `schemaVersion`+`contentVersion`、quiz/quiz_choice/glossary は `version` のみ、why_chains は `updatedAt` のみ。
3. **クイズの穴**: ○×がない雑学が8件（chimborazo_farthest, human_dna_same, flamingo_flamboyance, japan_islands, orbital_speed, shipping_80_percent, rice_half_world, wasabi_nose）。選択式は41件にだけ。
4. **`related` が一方向**（A→B があって B→A がない関係が147本）。仕様として明記するか、双方向にする。
5. **辞典の言語欠け**: 55語は5言語そろい、5語は1〜4言語（「本文に出てこない用語は外す」テストの仕様による）。
6. **Teen のみの雑学の規則**: Kids/Junior には出ない扱い。ほかのコンテンツでも同じ規則かを確認する。
7. **サイズ**: trivia.json 約590KB（全体約1MB）。数百件に増やすなら、言語別ファイル分割か遅延読み込みを検討。
8. **重複の持ち方**: `vocab` と `levels`（4段階×5言語）は手作業で増やすと食い違いやすい。`tool/content/*.py` の生成スクリプトに寄せる。

## 対応方針
1. 事実確認・出典付けの流れを作る（一覧スクリプト＋ `verification` の更新手順）。
2. メタ情報の名前・持ち方をそろえ、「全雑学にクイズがある」をテストにする。
3. `related` を双方向にするか決める。

## 対応状況
- 2（メタ情報）: 対応済み。全ファイルが `schemaVersion` / `contentVersion` / `updatedAt` / `items` の形（why_chains の `links` も `items` に）。テストで見張る。
- カテゴリーの追加: 対応済み。`assets/trivia/categories.json` に1件足せば、選択肢・図鑑・絞り込みに出る（コードの変更は不要）。
  - 項目: `id`, `order`, `emoji`, `status`(active/hidden), `labels`（ja は kids/junior/adult、ほかは文字列）。
  - 既存の9カテゴリーは、画面の言語ファイル（ARB）の名前が優先。新しいカテゴリーは `labels` から名前を出す。
  - 追加で見つかった不具合: 「japan」カテゴリーが選択肢になく、名前も出ていなかった（categories.json に追加して解消）。
- 1, 3（クイズの網羅テスト）, 4, 5〜8: 未対応。
