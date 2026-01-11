import 'dart:ui';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Using a custom implementation with BackdropFilter for better flexibility with dynamic height
    // GlassKit's GlassContainer often requires fixed height/width which is bad for lists
    return Container(
      margin:
          margin ?? const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).cardColor.withOpacity(0.7),
                  Theme.of(context).cardColor.withOpacity(0.3),
                ],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                child: Padding(
                  padding:
                      padding ??
                      const EdgeInsets.all(AppConstants.paddingMedium),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
