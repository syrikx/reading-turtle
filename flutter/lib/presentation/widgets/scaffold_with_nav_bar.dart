import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_navigation_bar.dart';

/// Scaffold with persistent navigation bar
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  final String? title;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null ? AppNavigationBar(title: title!) : null,
      body: child,
    );
  }
}
