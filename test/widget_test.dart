// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tugas4_praktikum/article_model.dart';
import 'package:tugas4_praktikum/main.dart';

void main() {
  testWidgets('displays food news as a list', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewsScreen(
          fetchArticles: () async => const [
            ArticleModel(
              judul: 'Berita makanan terbaru',
              deskripsi: 'Informasi seputar makanan.',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Berita Kuliner'), findsOneWidget);
    expect(find.text('BERITA MAKANAN'), findsOneWidget);
    expect(find.text('Berita makanan terbaru'), findsOneWidget);
  });
}
