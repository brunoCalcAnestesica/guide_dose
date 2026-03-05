import 'package:flutter/material.dart';

class NoFabAnimator extends FloatingActionButtonAnimator {
  const NoFabAnimator();

  @override
  Offset getOffset({
    required Offset begin,
    required Offset end,
    required double progress,
  }) {
    return end;
  }

  @override
  Animation<double> getScaleAnimation({required Animation<double> parent}) {
    return const AlwaysStoppedAnimation<double>(1.0);
  }

  @override
  Animation<double> getRotationAnimation({required Animation<double> parent}) {
    return const AlwaysStoppedAnimation<double>(0.0);
  }
}
