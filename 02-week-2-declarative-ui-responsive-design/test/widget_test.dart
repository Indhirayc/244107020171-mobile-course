import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_week_2/main.dart';
void main() {
  testWidgets('Academic Overview satu kolom di layar sempit', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AcademicApp());

    final cards = find.byType(InfoCard);

    expect(cards, findsNWidgets(4));

    final firstCard = tester.getTopLeft(cards.at(0));
    final secondCard = tester.getTopLeft(cards.at(1));

    expect(secondCard.dy, greaterThan(firstCard.dy));
  });

  testWidgets('Academic Overview dua kolom di layar lebar', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AcademicApp());

    final cards = find.byType(InfoCard);

    expect(cards, findsNWidgets(4));

    final firstCard = tester.getTopLeft(cards.at(0));
    final secondCard = tester.getTopLeft(cards.at(1));

    expect(secondCard.dx, greaterThan(firstCard.dx));
  });
}