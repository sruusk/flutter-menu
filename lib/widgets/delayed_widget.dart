import 'package:flutter/material.dart';

class DelayedWidget extends StatefulWidget {
  final Widget child;
  final Widget? placeholder;
  final Duration delay;

  const DelayedWidget({super.key, required this.child, this.placeholder, required this.delay});

  @override
  State<DelayedWidget> createState() => _DelayedWidgetState();
}

class _DelayedWidgetState extends State<DelayedWidget> with SingleTickerProviderStateMixin {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
    return _visible ? widget.child : widget.placeholder ?? Container();
  }
}
