import 'package:awesome_snackbar_content/src/default_colors.dart';
import 'package:flutter/cupertino.dart';

/// to handle failure, success, help and warning `ContentType` class is being used
class ContentType {
  /// message is `required` parameter
  final String message;

  /// color is optional, if provided null then `DefaultColors` will be used
  final Color? color;

  const ContentType(this.message, [this.color]);

  static const ContentType help = ContentType('help', DefaultColors.helpBlue);
  static const ContentType failure = ContentType('failure', DefaultColors.failureRed);
  static const ContentType success = ContentType('success', DefaultColors.successGreen);
  static const ContentType warning = ContentType('warning', DefaultColors.warningYellow);
}

enum Position {
  top,
  center,
  bottom,
}

enum AnimationType {
  fromTop,
  fromLeft,
  fromRight,
  fromBottom,
}

extension PositionExtension on Position {
  AlignmentGeometry get alignment {
    switch (this) {
      case Position.center:
        return Alignment.center;
      case Position.top:
        return Alignment.topCenter;
      case Position.bottom:
        return Alignment.bottomCenter;
    }
  }
}
