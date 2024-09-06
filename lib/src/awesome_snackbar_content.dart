import 'dart:async';
import 'dart:ui' as ui;

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AwesomeSnackbarContent extends StatefulWidget {
  //Overlay that does not block the screen
  OverlayEntry? overlayEntry;

  /// title is the header String that will show on top
  final String title;

  /// message String is the body message which shows only 2 lines at max
  final String message;

  /// `optional` color of the SnackBar body
  final Color? color;

  /// contentType will reflect the overall theme of SnackBar: failure, success, help, warning
  final ContentType contentType;

  /// if you want to customize the font size of the title
  final double? titleFontSize;

  /// if you want to customize the font size of the message
  final double? messageFontSize;

  /// if you don't want to show the close icon
  final bool showCloseIcon;

  ///the snackbar display postion, possible values
  ///```dart
  ///{
  ///top,
  ///bottom
  ///}
  ///```
  final Position position;

  ///The duration of the animation by default it's 1.5 seconds
  ///
  final Duration animationDuration;

  ///the animation curve by default it's set to `Curves.ease`
  ///
  final Cubic animationCurve;

  ///The animation type applied on the snackbar
  ///```dart
  ///{
  ///fromTop,
  ///fromLeft,
  ///fromRight
  ///}
  ///```
  final AnimationType animationType;

  ///indicates whether the snackbar will be hidden automatically or not
  ///
  final bool autoDismiss;

  ///the duration of the toast if [autoDismiss] is true
  ///by default it's 3 seconds
  ///
  final Duration duration;

  ///Callback invoked when snackbar get dismissed (closed by button or dismissed automatically)
  final Function()? onClosed;

  AwesomeSnackbarContent({
    super.key,
    this.color,
    this.titleFontSize,
    this.messageFontSize,
    required this.title,
    required this.message,
    required this.contentType,
    this.showCloseIcon = true,
    this.position = Position.top,
    this.animationDuration = const Duration(
      milliseconds: 1500,
    ),
    this.animationCurve = Curves.ease,
    this.animationType = AnimationType.fromLeft,
    this.autoDismiss = true,
    this.duration = const Duration(
      milliseconds: 3000,
    ),
    this.onClosed,
  });

  void show(BuildContext context) {
    overlayEntry = _overlayEntryBuilder();
    final overlay = Overlay.maybeOf(context);

    if (overlay != null) {
      overlay.insert(overlayEntry!);
    } else {
      Navigator.of(context).overlay?.insert(overlayEntry!);
    }
  }

  void closeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(
      opaque: false,
      builder: (context) {
        return SafeArea(
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            alignment: position.alignment,
            contentPadding: EdgeInsets.zero,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            content: this,
          ),
        );
      },
    );
  }

  @override
  State<AwesomeSnackbarContent> createState() => AwesomeSnackbarContentState();
}

class AwesomeSnackbarContentState extends State<AwesomeSnackbarContent> with TickerProviderStateMixin {
  late Animation<Offset> offsetAnimation;
  late AnimationController slideController;
  Timer? autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _initAnimation();

    if (widget.autoDismiss) {
      autoDismissTimer = Timer(widget.duration, () {
        slideController.reverse();
        Timer(widget.animationDuration, () {
          widget.closeOverlay();
        });
      });
    }
  }

  @override
  void dispose() {
    widget.onClosed?.call();
    autoDismissTimer?.cancel();
    slideController.dispose();
    super.dispose();
  }

  ///Initialize animation parameters [slideController] and [offsetAnimation]
  void _initAnimation() {
    slideController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    switch (widget.animationType) {
      case AnimationType.fromLeft:
        offsetAnimation = Tween<Offset>(
          begin: const Offset(-2, 0),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(
            parent: slideController,
            curve: widget.animationCurve,
          ),
        );
        break;
      case AnimationType.fromRight:
        offsetAnimation = Tween<Offset>(
          begin: const Offset(2, 0),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(
            parent: slideController,
            curve: widget.animationCurve,
          ),
        );
        break;
      case AnimationType.fromTop:
        offsetAnimation = Tween<Offset>(
          begin: const Offset(0, -2),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(
            parent: slideController,
            curve: widget.animationCurve,
          ),
        );
        break;
      case AnimationType.fromBottom:
        offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 2),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(
            parent: slideController,
            curve: widget.animationCurve,
          ),
        );
        break;
      default:
    }

    /// ! To support Flutter < 3.0.0
    /// This allows a value of type T or T?
    /// to be treated as a value of type T?.
    ///
    /// We use this so that APIs that have become
    /// non-nullable can still be used with `!` and `?`
    /// to support older versions of the API as well.
    T? ambiguate<T>(T? value) => value;

    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
      slideController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isRTL = Directionality.of(context) == TextDirection.rtl;
    final size = MediaQuery.sizeOf(context);

    // screen dimensions
    bool isMobile = size.width <= 768;
    bool isTablet = size.width > 768 && size.width <= 992;

    /// for reflecting different color shades in the SnackBar
    final hsl = HSLColor.fromColor(widget.color ?? widget.contentType.color!);
    final hslDark = hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0));

    double horizontalPadding = 0.0;
    double leftSpace = size.width * 0.12;
    double rightSpace = size.width * 0.12;

    if (isMobile) {
      horizontalPadding = size.width * 0.01;
    } else if (isTablet) {
      leftSpace = size.width * 0.05;
      horizontalPadding = size.width * 0.2;
    } else {
      leftSpace = size.width * 0.05;
      horizontalPadding = size.width * 0.3;
    }

    final width = size.width - ((leftSpace * 2) + 10) - rightSpace - (horizontalPadding * 2) - (size.width * 0.03);
    final lines = _numberOfLines(
      text: widget.message,
      maxWidth: width,
      style: TextStyle(
        fontSize: widget.messageFontSize ?? size.height * 0.016,
        color: Colors.white,
      ),
    );

    return SlideTransition(
      position: offsetAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
        ),
        height: size.height * (lines > 2 ? 0.15 : 0.125),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            /// background container
            Container(
              width: size.width,
              decoration: BoxDecoration(
                color: widget.color ?? widget.contentType.color,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            /// Splash SVG asset
            Positioned(
              bottom: 0,
              left: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                ),
                child: SvgPicture.asset(
                  AssetsPath.bubbles,
                  height: size.height * 0.06,
                  width: size.width * 0.05,
                  colorFilter: _getColorFilter(hslDark.toColor(), ui.BlendMode.srcIn),
                  package: 'awesome_snackbar_content',
                ),
              ),
            ),

            // Bubble Icon
            Positioned(
              top: -size.height * 0.02,
              left: !isRTL ? leftSpace - 8 - (isMobile ? size.width * 0.075 : size.width * 0.035) : null,
              right: isRTL ? rightSpace - 8 - (isMobile ? size.width * 0.075 : size.width * 0.035) : null,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    AssetsPath.back,
                    height: size.height * 0.06,
                    colorFilter: _getColorFilter(hslDark.toColor(), ui.BlendMode.srcIn),
                    package: 'awesome_snackbar_content',
                  ),
                  Positioned(
                    top: size.height * 0.015,
                    child: SvgPicture.asset(
                      assetSVG(widget.contentType),
                      height: size.height * 0.022,
                      package: 'awesome_snackbar_content',
                    ),
                  )
                ],
              ),
            ),

            /// content
            Positioned.fill(
              left: isRTL ? size.width * 0.03 : leftSpace + 10,
              right: isRTL ? rightSpace : size.width * 0.03,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * (lines > 2 ? 0.005 : 0.01),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// `title` parameter
                      Expanded(
                        flex: 3,
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: widget.titleFontSize ?? (!isMobile ? size.height * 0.03 : size.height * 0.025),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // InkWell(
                      //   onTap: () {
                      //     if (inMaterialBanner) {
                      //       ScaffoldMessenger.of(context)
                      //           .hideCurrentMaterialBanner();
                      //       return;
                      //     }
                      //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      //   },
                      //   child: SvgPicture.asset(
                      //     AssetsPath.failure,
                      //     height: size.height * 0.022,
                      //     package: 'awesome_snackbar_content',
                      //   ),
                      // ),

                      IconButton(
                        onPressed: () {
                          if (!widget.showCloseIcon) {
                            return;
                          }

                          slideController.reverse();
                          autoDismissTimer?.cancel();

                          Timer(widget.animationDuration, () {
                            widget.closeOverlay();
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          color: widget.showCloseIcon ? Colors.white : Colors.transparent,
                          size: size.height * 0.022,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.001,
                  ),

                  /// `message` body text parameter
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: widget.messageFontSize ?? size.height * 0.016,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.015,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Reflecting proper icon based on the contentType
  String assetSVG(ContentType contentType) {
    switch (contentType) {
      case ContentType.failure:

        /// failure will show `CROSS`
        return AssetsPath.failure;
      case ContentType.success:

        /// success will show `CHECK`
        return AssetsPath.success;
      case ContentType.warning:

        /// warning will show `EXCLAMATION`
        return AssetsPath.warning;
      case ContentType.help:

        /// help will show `QUESTION MARK`
        return AssetsPath.help;
      default:
        return AssetsPath.failure;
    }
  }

  int _numberOfLines({
    required String text,
    required double maxWidth,
    TextStyle? style,
  }) {
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );

    tp.layout(maxWidth: maxWidth);
    return tp.computeLineMetrics().length;
  }

  ColorFilter? _getColorFilter(ui.Color? color, ui.BlendMode colorBlendMode) => color == null ? null : ui.ColorFilter.mode(color, colorBlendMode);
}
