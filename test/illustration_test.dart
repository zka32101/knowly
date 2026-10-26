import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/widgets/illustration.dart';

void main() {
  testWidgets('画像がない絵は、絵文字で出る', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TriviaIllustration(id: 'octopus')),
    );
    expect(find.text('🐙'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('画像がある絵は画像で出て、読めなければ絵文字に戻る', (tester) async {
    illustrationImages.add('octopus');
    addTearDown(() => illustrationImages.remove('octopus'));
    await tester.pumpWidget(
      const MaterialApp(home: TriviaIllustration(id: 'octopus')),
    );
    expect(find.byKey(const Key('illustration_image_octopus')), findsOneWidget);
    await tester.pumpAndSettle();
    // assets/illustrations/octopus.png はまだ無いので、読めずに絵文字へ戻る
    expect(find.text('🐙'), findsOneWidget);
  });

  test('絵の一覧に、知らない絵の id は 💡 で出る', () {
    expect(emojiForIllustration('no_such_illustration'), '💡');
  });
}
