import 'package:flutter/material.dart';
import 'package:inves_tracker/core/constants/app_colors.dart';
import 'package:inves_tracker/core/utils/theme_notifier.dart';
import 'package:provider/provider.dart';

class ThemedTransitionWrapper extends StatefulWidget {
  final Widget child;

  const ThemedTransitionWrapper({super.key, required this.child});

  @override
  State<ThemedTransitionWrapper> createState() =>
      _ThemedTransitionWrapperState();
}

class _ThemedTransitionWrapperState extends State<ThemedTransitionWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  
  AppThemeMode? _lastMode;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      // A slightly faster duration feels more responsive
      duration: const Duration(milliseconds: 200),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastLinearToSlowEaseIn,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Safely listen to theme changes outside the build method
    final currentMode = Provider.of<ThemeNotifier>(context).currentMode;
    
    if (_lastMode == null) {
      _lastMode = currentMode;
    } else if (_lastMode != currentMode) {
      _lastMode = currentMode;
      
      // Briefly dip the opacity, then bring it back up.
      _controller.forward().then((_) {
        if (mounted) _controller.reverse();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Clean build method with no side effects!
    return FadeTransition(
      opacity: _opacity,
      child: widget.child,
    );
  }
}