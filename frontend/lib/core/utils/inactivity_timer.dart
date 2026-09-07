import 'dart:async';
import 'package:flutter/material.dart';

class InactivityWatchdog extends StatefulWidget {
  final Widget child;
  final VoidCallback onTimeout;
  final Duration timeout;

  const InactivityWatchdog({
    super.key,
    required this.child,
    required this.onTimeout,
    this.timeout = const Duration(seconds: 90),
  });

  @override
  State<InactivityWatchdog> createState() => _InactivityWatchdogState();
}

class _InactivityWatchdogState extends State<InactivityWatchdog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeout, widget.onTimeout);
  }

  void _handleUserInteraction([_]) {
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handleUserInteraction,
      onPointerMove: _handleUserInteraction,
      child: widget.child,
    );
  }
}
