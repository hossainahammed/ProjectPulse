import 'package:flutter/material.dart';

/// =======================================================
/// UNIVERSAL RESPONSIVE SYSTEM
/// Use in every Flutter project
/// =======================================================

class AppResponsive {
  final BuildContext context;

  AppResponsive(this.context);

  static AppResponsive of(BuildContext context) {
    return AppResponsive(context);
  }

  // =======================================================
  // SCREEN SIZE
  // =======================================================

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;

  double get topPadding => MediaQuery.of(context).padding.top;
  double get bottomPadding => MediaQuery.of(context).padding.bottom;

  // =======================================================
  // BREAKPOINTS
  // =======================================================

  bool get isSmallPhone => width < 360;

  bool get isMobile => width >= 360 && width < 600;

  bool get isTablet => width >= 600 && width < 1024;

  bool get isDesktop => width >= 1024;

  bool get isLargeScreen => width >= 600;

  // =======================================================
  // BASE WIDTH
  // =======================================================

  static const double _baseWidth = 390;

  // =======================================================
  // FONT SCALING
  // =======================================================

  double font(double size) {
    double scaleFactor = width / _baseWidth;

    if (isTablet) {
      scaleFactor = 1.10;
    }

    if (isDesktop) {
      scaleFactor = 1.20;
    }

    return size * scaleFactor.clamp(0.9, 1.3);
  }

  // =======================================================
  // SPACING SCALING
  // =======================================================

  double space(double size) {
    double scaleFactor = width / _baseWidth;

    return size * scaleFactor.clamp(0.85, 1.2);
  }

  // =======================================================
  // COMMON FONT SIZES
  // =======================================================

  double get fontXS => font(10);

  double get fontSM => font(12);

  double get fontMD => font(14);

  double get fontBase => font(16);

  double get fontLG => font(18);

  double get fontXL => font(20);

  double get font2XL => font(24);

  double get font3XL => font(28);

  double get font4XL => font(32);

  double get font5XL => font(40);

  // =======================================================
  // COMMON SPACING
  // =======================================================

  double get spaceXS => space(4);

  double get spaceSM => space(8);

  double get spaceMD => space(12);

  double get spaceLG => space(16);

  double get spaceXL => space(20);

  double get space2XL => space(24);

  double get space3XL => space(32);

  double get space4XL => space(40);

  double get space5XL => space(48);

  double get space6XL => space(60);

  // =======================================================
  // RESPONSIVE PADDING
  // =======================================================

  double get horizontalPadding {
    if (isDesktop) {
      return width * 0.15;
    }

    if (isTablet) {
      return width * 0.08;
    }

    if (isSmallPhone) {
      return 16;
    }

    return 20;
  }

  // =======================================================
  // RESPONSIVE WIDGET SIZE
  // =======================================================

  double size(double value) {
    double scaleFactor = width / _baseWidth;

    return value * scaleFactor.clamp(0.9, 1.2);
  }

  // =======================================================
  // COMMON COMPONENT HEIGHTS
  // =======================================================

  double get buttonHeight {
    if (isTablet) return 56;
    if (isDesktop) return 60;

    return 48;
  }

  double get textFieldHeight {
    if (isTablet) return 60;

    return 52;
  }

  double get appBarHeight {
    return isTablet ? 70 : 56;
  }

  // =======================================================
  // RESPONSIVE WIDTH
  // =======================================================

  double responsiveWidth({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop) {
      return desktop ?? tablet ?? mobile;
    }

    if (isTablet) {
      return tablet ?? mobile;
    }

    return mobile;
  }

  // =======================================================
  // RESPONSIVE HEIGHT
  // =======================================================

  double responsiveHeight({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop) {
      return desktop ?? tablet ?? mobile;
    }

    if (isTablet) {
      return tablet ?? mobile;
    }

    return mobile;
  }
}

/// =======================================================
/// CONTEXT EXTENSION
/// Usage:
/// context.res.fontBase
/// =======================================================

extension ResponsiveExtension on BuildContext {
  AppResponsive get res => AppResponsive.of(this);
}
