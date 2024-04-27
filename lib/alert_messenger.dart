import 'package:flutter/material.dart';

const kAlertHeight = 80.0;

enum AlertPriority {
  error(2),
  warning(1),
  info(0);

  const AlertPriority(this.value);
  final int value;
}

class Alert extends StatelessWidget {
  const Alert({
    super.key,
    required this.backgroundColor,
    required this.child,
    required this.leading,
    required this.priority,
  });

  final Color backgroundColor;
  final Widget child;
  final Widget leading;
  final AlertPriority priority;

  @override
  Widget build(BuildContext context) {
    final statusbarHeight = MediaQuery.of(context).padding.top;
    return Material(
      child: Ink(
        color: backgroundColor,
        height: kAlertHeight + statusbarHeight,
        child: Column(
          children: [
            SizedBox(height: statusbarHeight),
            Expanded(
              child: Row(
                children: [
                  const SizedBox(width: 28.0),
                  IconTheme(
                    data: const IconThemeData(
                      color: Colors.white,
                      size: 36,
                    ),
                    child: leading,
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: DefaultTextStyle(
                      style: const TextStyle(color: Colors.white),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 28.0),
          ],
        ),
      ),
    );
  }
}

class AlertMessenger extends StatefulWidget {
  const AlertMessenger({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, String text) builder;

  @override
  State<AlertMessenger> createState() => AlertMessengerState();

  static AlertMessengerState of(BuildContext context) {
    try {
      final scope = _AlertMessengerScope.of(context);
      return scope.state;
    } catch (error) {
      throw FlutterError.fromParts(
        [
          ErrorSummary('No AlertMessenger was found in the Element tree'),
          ErrorDescription('AlertMessenger is required in order to show and hide alerts.'),
          ...context.describeMissingAncestor(expectedAncestorType: AlertMessenger),
        ],
      );
    }
  }
}

class AlertMessengerState extends State<AlertMessenger> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;
  final _duration = const Duration(milliseconds: 300);
  bool _hasAlert = false;

  List<Widget> alerts = List.generate(
    AlertPriority.values.length,
    (index) => const SizedBox.shrink(),
  );

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      AlertPriority.values.length,
      (_) => AnimationController(
        duration: _duration,
        vsync: this,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final alertHeight = MediaQuery.of(context).padding.top + kAlertHeight;
    _animations = List.generate(
      AlertPriority.values.length,
      (index) => Tween<double>(begin: -alertHeight, end: 0.0).animate(
        CurvedAnimation(parent: _controllers[index], curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void showAlert({required Alert alert}) {
    setState(() {
      alerts[alert.priority.value] = alert;
      _hasAlert = true;
    });
    _controllers[alert.priority.value].forward();
  }

  void hideAlert() {
    for (int i = _controllers.length - 1; i >= 0; i--) {
      if (_controllers[i].status == AnimationStatus.completed) {
        setState(() {
          _hasAlert = _controllers.where((element) => element.status == AnimationStatus.dismissed).length <= 1;
        });
        _controllers[i].reverse().whenComplete(() {
          setState(() {
            alerts[i] = const SizedBox.shrink();
          });
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusbarHeight = MediaQuery.of(context).padding.top;

    final alertHeight = _hasAlert ? 0.0 : statusbarHeight + kAlertHeight;

    final position = -alertHeight + kAlertHeight;

    String text = '';

    for (int i = alerts.length - 1; i >= 0; i--) {
      final alert = alerts[i];
      if (alert is Alert) {
        text = alert.child is Text ? (alert.child as Text).data ?? '' : '';
        break;
      }
    }

    return Stack(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      children: [
        AnimatedPositioned(
          duration: _duration,
          curve: Curves.easeInOut,
          left: 0,
          right: 0,
          bottom: 0,
          top: position <= statusbarHeight ? 0 : position - statusbarHeight,
          child: _AlertMessengerScope(
            state: this,
            child: Builder(
              builder: (context) => widget.builder.call(context, text),
            ),
          ),
        ),
        for (int i = 0; i < _controllers.length; i++)
          AnimatedBuilder(
            animation: _animations[i],
            builder: (context, child) {
              return Positioned(
                top: _animations[i].value,
                left: 0,
                right: 0,
                child: alerts[i],
              );
            },
          ),
      ],
    );
  }
}

class _AlertMessengerScope extends InheritedWidget {
  const _AlertMessengerScope({
    required this.state,
    required super.child,
  });

  final AlertMessengerState state;

  @override
  bool updateShouldNotify(_AlertMessengerScope oldWidget) => state != oldWidget.state;

  static _AlertMessengerScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AlertMessengerScope>();
  }

  static _AlertMessengerScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No _AlertMessengerScope found in context');
    return scope!;
  }
}
