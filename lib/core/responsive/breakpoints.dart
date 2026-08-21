import 'package:flutter/widgets.dart';

abstract final class Breakpoints {
  static const tablet = 600.0;
  static const desktop = 1024.0;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;
}
