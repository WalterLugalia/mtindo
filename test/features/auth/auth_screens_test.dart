import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtindo_app/core/errors/failure.dart';
import 'package:mtindo_app/features/auth/providers/auth_provider.dart';
import 'package:mtindo_app/features/auth/screens/login_screen.dart';
import 'package:mtindo_app/features/auth/screens/signup_screen.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  /// Types [text] into the nth text field on the screen (0 = first).
  Future<void> typeInto(WidgetTester tester, int index, String text) {
    return tester.enterText(find.byType(TextFormField).at(index), text);
  }

  group('LoginScreen', () {
    Future<FakeAuthController> pumpLogin(WidgetTester tester) async {
      useTallScreen(tester);
      final controller = FakeAuthController();
      await pumpScreen(
        tester,
        const LoginScreen(),
        overrides: [authControllerProvider.overrideWith(() => controller)],
      );
      return controller;
    }

    testWidgets('shows both errors and sends nothing when submitted empty', (tester) async {
      final controller = await pumpLogin(tester);

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsOneWidget);
      expect(controller.signIns, isEmpty);
    });

    testWidgets('rejects an email that is not shaped like an email', (tester) async {
      final controller = await pumpLogin(tester);

      await typeInto(tester, 0, 'abc');
      await typeInto(tester, 1, 'secret');
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(controller.signIns, isEmpty);
    });

    testWidgets('requires a password even when the email is fine', (tester) async {
      final controller = await pumpLogin(tester);

      await typeInto(tester, 0, 'a@b.co');
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your password.'), findsOneWidget);
      expect(controller.signIns, isEmpty);
    });

    testWidgets('sends the trimmed email and the password untouched', (tester) async {
      final controller = await pumpLogin(tester);

      await typeInto(tester, 0, '  a@b.co  ');
      await typeInto(tester, 1, 'secret');
      await tester.tap(find.text('Log in'));
      await tester.pump();

      expect(controller.signIns, hasLength(1));
      expect(controller.signIns.single.email, 'a@b.co');
      expect(controller.signIns.single.password, 'secret');
    });

    testWidgets('accepts a short password, because the length rule is for signup only', (tester) async {
      final controller = await pumpLogin(tester);

      await typeInto(tester, 0, 'a@b.co');
      await typeInto(tester, 1, 'abc');
      await tester.tap(find.text('Log in'));
      await tester.pump();

      expect(controller.signIns, hasLength(1));
    });

    testWidgets('shows the error when sign-in fails', (tester) async {
      final controller = await pumpLogin(tester);
      controller.nextState = AsyncError<void>(
        const AuthFailure('Incorrect email or password.'),
        StackTrace.empty,
      );

      await typeInto(tester, 0, 'a@b.co');
      await typeInto(tester, 1, 'wrong');
      await tester.tap(find.text('Log in'));
      await tester.pump();

      expect(find.text('Incorrect email or password.'), findsOneWidget);
    });

    testWidgets('shows a spinner while signing in', (tester) async {
      final controller = await pumpLogin(tester);
      controller.nextState = AsyncLoading<void>();

      await typeInto(tester, 0, 'a@b.co');
      await typeInto(tester, 1, 'secret');
      await tester.tap(find.text('Log in'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('"Create account" opens the signup screen', (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(find.text('STUB SIGNUP'), findsOneWidget);
    });
  });

  group('SignupScreen', () {
    Future<FakeAuthController> pumpSignup(WidgetTester tester) async {
      useTallScreen(tester);
      final controller = FakeAuthController();
      await pumpScreen(
        tester,
        const SignupScreen(),
        overrides: [authControllerProvider.overrideWith(() => controller)],
      );
      return controller;
    }

    // Field order on the signup screen: 0 name, 1 email, 2 password,
    // 3 confirm password.

    testWidgets('shows an error under every field when submitted empty', (tester) async {
      final controller = await pumpSignup(tester);

      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your name.'), findsOneWidget);
      expect(find.text('Please enter your email.'), findsOneWidget);
      expect(find.text('Please create a password.'), findsOneWidget);
      expect(find.text('Please enter your password again.'), findsOneWidget);
      expect(controller.signUps, isEmpty);
    });

    testWidgets('rejects a password shorter than the minimum', (tester) async {
      final controller = await pumpSignup(tester);

      await typeInto(tester, 0, 'Walter');
      await typeInto(tester, 1, 'a@b.co');
      await typeInto(tester, 2, 'abc');
      await typeInto(tester, 3, 'abc');
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(find.textContaining('at least'), findsOneWidget);
      expect(controller.signUps, isEmpty);
    });

    testWidgets('rejects a confirmation that does not match', (tester) async {
      final controller = await pumpSignup(tester);

      await typeInto(tester, 0, 'Walter');
      await typeInto(tester, 1, 'a@b.co');
      await typeInto(tester, 2, 'secret1');
      await typeInto(tester, 3, 'secret2');
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
      expect(controller.signUps, isEmpty);
    });

    testWidgets('rejects an email that is not shaped like an email', (tester) async {
      final controller = await pumpSignup(tester);

      await typeInto(tester, 0, 'Walter');
      await typeInto(tester, 1, 'nope');
      await typeInto(tester, 2, 'secret1');
      await typeInto(tester, 3, 'secret1');
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(controller.signUps, isEmpty);
    });

    testWidgets('sends trimmed name and email when everything is valid', (tester) async {
      final controller = await pumpSignup(tester);

      await typeInto(tester, 0, '  Walter  ');
      await typeInto(tester, 1, '  a@b.co  ');
      await typeInto(tester, 2, 'secret1');
      await typeInto(tester, 3, 'secret1');
      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(controller.signUps, hasLength(1));
      expect(controller.signUps.single.name, 'Walter');
      expect(controller.signUps.single.email, 'a@b.co');
      expect(controller.signUps.single.password, 'secret1');
    });
  });
}