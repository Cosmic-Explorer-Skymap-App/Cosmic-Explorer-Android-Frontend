import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cosmic_explorer/app.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('renders home screen with app title', (tester) async {
      await tester.pumpWidget(const CosmicExplorerApp());
      await tester.pumpAndSettle();

      expect(find.text('🌌 Cosmic Explorer'), findsOneWidget);
    });

    testWidgets('renders bottom navigation bar with 5 items', (tester) async {
      await tester.pumpWidget(const CosmicExplorerApp());
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Ana Sayfa'), findsOneWidget);
      // 'Gezegenler' appears in both nav and quick action, so find at least one
      expect(find.text('Gezegenler'), findsWidgets);
      expect(find.text('Yıldızlar'), findsOneWidget);
      expect(find.text('Quiz'), findsOneWidget);
      expect(find.text('Favoriler'), findsOneWidget);
    });

    testWidgets('renders sky map CTA card', (tester) async {
      await tester.pumpWidget(const CosmicExplorerApp());
      await tester.pumpAndSettle();

      expect(find.text('Canlı Gök Haritası'), findsOneWidget);
      expect(find.text('Başla →'), findsOneWidget);
    });

    testWidgets('renders daily fact section', (tester) async {
      await tester.pumpWidget(const CosmicExplorerApp());
      await tester.pumpAndSettle();

      expect(find.text('Günün Uzay Gerçeği'), findsOneWidget);
    });

    testWidgets('navigating to planets tab shows planet list', (tester) async {
      await tester.pumpWidget(const CosmicExplorerApp());
      await tester.pumpAndSettle();

      // Tap the bottom nav item specifically
      final navBar = find.byType(BottomNavigationBar);
      expect(navBar, findsOneWidget);
      // Tap on "Gezegenler" in the bottom nav by finding the icon
      await tester.tap(find.byIcon(Icons.public_rounded));
      await tester.pumpAndSettle();

      expect(find.text('🪐 Güneş Sistemi'), findsOneWidget);
      expect(find.text('Merkür'), findsOneWidget);
    });

    testWidgets('navigating to constellations tab shows list', (tester) async {
      await tester.pumpWidget(const CosmicExplorerApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      expect(find.text('⭐ Takımyıldızlar'), findsOneWidget);
    });

    testWidgets('navigating to quiz tab shows quiz', (tester) async {
      await tester.pumpWidget(const CosmicExplorerApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.quiz_rounded));
      await tester.pumpAndSettle();

      expect(find.text('🧠 Astronomi Quiz'), findsOneWidget);
    });
  });
}
