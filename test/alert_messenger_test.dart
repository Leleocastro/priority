import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:priority/alert_messenger.dart';

void main() {
  final baseApp = MaterialApp(
    home: Scaffold(
      body: AlertMessenger(
        builder: (context, text) => const Text('Testando'),
      ),
    ),
  );
  testWidgets('Teste do widget Alert', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlertMessenger(
            builder: (context, text) => const Alert(
              backgroundColor: Colors.red,
              leading: Icon(Icons.error),
              priority: AlertPriority.error,
              child: Text('Teste'),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Alert), findsOneWidget);
    expect(find.text('Teste'), findsOneWidget);
    expect(find.byIcon(Icons.error), findsOneWidget);
    expect(find.byType(Ink), findsOneWidget);
  });

  testWidgets('Teste do widget AlertMessenger', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlertMessenger(
            builder: (context, text) => Text(text),
          ),
        ),
      ),
    );

    expect(find.byType(AlertMessenger), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('Teste do método AlertMessenger.of', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlertMessenger(
            builder: (context, text) => Text(text),
          ),
        ),
      ),
    );

    AlertMessengerState state = AlertMessenger.of(tester.element(find.byType(Text)));
    expect(state, isNotNull);
  });
  testWidgets('Teste do erro do método AlertMessenger.of', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Container(),
        ),
      ),
    );

    expect(() => AlertMessenger.of(tester.element(find.byType(Container))), throwsA(isA<FlutterError>()));
  });
  testWidgets('Teste do método updateShouldNotify', (WidgetTester tester) async {
    int buildCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlertMessenger(
            builder: (context, text) {
              buildCount++;
              return const Text('Testando');
            },
          ),
        ),
      ),
    );

    expect(buildCount, 1);

    AlertMessenger.of(tester.element(find.text('Testando'))).showAlert(
        alert: const Alert(
      backgroundColor: Colors.red,
      leading: SizedBox.shrink(),
      priority: AlertPriority.error,
      child: Text('Teste'),
    ));

    await tester.pump();

    expect(buildCount, 2);
  });
  testWidgets('Teste do método showAlert', (WidgetTester tester) async {
    await tester.pumpWidget(
      baseApp,
    );

    AlertMessengerState state = AlertMessenger.of(tester.element(find.text('Testando')));

    expect(state.alerts.every((element) => element is SizedBox), true);

    state.showAlert(
      alert: const Alert(
        backgroundColor: Colors.red,
        leading: SizedBox.shrink(),
        priority: AlertPriority.error,
        child: Text('Teste'),
      ),
    );

    await tester.pump();

    expect(state.alerts[AlertPriority.error.value] is Alert, true);
  });

  testWidgets('Teste do método hideAlert', (WidgetTester tester) async {
    await tester.pumpWidget(
      baseApp,
    );

    AlertMessengerState state = AlertMessenger.of(tester.element(find.text('Testando')));

    state.showAlert(
      alert: const Alert(
        backgroundColor: Colors.red,
        leading: SizedBox.shrink(),
        priority: AlertPriority.error,
        child: Text('Teste'),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(state.alerts[AlertPriority.error.value] is Alert, true);

    state.hideAlert();

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(state.alerts[AlertPriority.error.value] is SizedBox, true);
  });

  testWidgets('Teste de prioridade de alertas', (WidgetTester tester) async {
    await tester.pumpWidget(
      baseApp,
    );

    AlertMessengerState state = AlertMessenger.of(tester.element(find.text('Testando')));

    state.showAlert(
      alert: const Alert(
        backgroundColor: Colors.red,
        leading: SizedBox.shrink(),
        priority: AlertPriority.error,
        child: Text('Erro'),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Erro').hitTestable(), findsOneWidget);

    state.showAlert(
      alert: const Alert(
        backgroundColor: Colors.yellow,
        leading: SizedBox.shrink(),
        priority: AlertPriority.warning,
        child: Text('Alerta'),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Erro').hitTestable(), findsOneWidget);
    expect(find.text('Alerta').hitTestable(), findsNothing);

    state.showAlert(
      alert: const Alert(
        backgroundColor: Colors.yellow,
        leading: SizedBox.shrink(),
        priority: AlertPriority.info,
        child: Text('Info'),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Erro').hitTestable(), findsOneWidget);
    expect(find.text('Alerta').hitTestable(), findsNothing);
    expect(find.text('Info').hitTestable(), findsNothing);

    state.hideAlert();

    await tester.pumpAndSettle();

    expect(find.text('Erro').hitTestable(), findsNothing);
    expect(find.text('Alerta').hitTestable(), findsOneWidget);
    expect(find.text('Info').hitTestable(), findsNothing);

    state.hideAlert();

    await tester.pumpAndSettle();

    expect(find.text('Erro').hitTestable(), findsNothing);
    expect(find.text('Alerta').hitTestable(), findsNothing);
    expect(find.text('Info').hitTestable(), findsOneWidget);

    state.hideAlert();

    await tester.pumpAndSettle();

    expect(find.text('Erro').hitTestable(), findsNothing);
    expect(find.text('Alerta').hitTestable(), findsNothing);
    expect(find.text('Info').hitTestable(), findsNothing);
  });

  testWidgets('Teste da alteração do texto', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlertMessenger(
            builder: (context, text) => Text(text),
          ),
        ),
      ),
    );

    AlertMessengerState state = AlertMessenger.of(tester.element(find.byType(Text)));

    expect(find.byType(AlertMessenger), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
    expect(find.text(''), findsOneWidget);

    state.showAlert(
      alert: const Alert(
        backgroundColor: Colors.yellow,
        leading: SizedBox.shrink(),
        priority: AlertPriority.info,
        child: Text('Info'),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Info'), findsNWidgets(2));
  });
}
