import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'startup_diagnostics.dart';

const splashBackground = Color(0xFF0A0F0C);
const radarCenter = Offset(540, 840);
const radarContacts = [
  RadarContact(Offset(820, 636)),
  RadarContact(Offset(340, 580)),
  RadarContact(Offset(280, 1040)),
  RadarContact(Offset(690, 1200)),
];

class RadarContact {
  const RadarContact(this.position);
  final Offset position;

  /// Clockwise bearing, with zero at twelve o'clock.
  double get phase {
    final relative = position - radarCenter;
    return ((math.atan2(relative.dy, relative.dx) + math.pi / 2) %
            (math.pi * 2)) /
        (math.pi * 2);
  }

  /// A contact lights up only after the beam reaches its bearing.
  double activityAt(double turns) {
    // Avoid a missed crossing at an exact lap boundary due to floating point.
    final elapsed = turns - phase + 1e-9;
    if (elapsed < 0) return 0;
    final age = elapsed - elapsed.floorToDouble();
    if (age >= .30) return 0;
    if (age <= .05) return 1;
    return 1 - (age - .05) / .25;
  }
}

/// The same animation drives the sweep, contact pulses and loading bar.
class StartupScreen extends StatefulWidget {
  const StartupScreen({
    required this.child,
    this.displayDuration = const Duration(milliseconds: 4500),
    this.imagesToPrecache = const <ImageProvider>[],
    super.key,
  });
  final Widget child;
  final Duration displayDuration;
  final List<ImageProvider> imagesToPrecache;

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.displayDuration,
    animationBehavior: AnimationBehavior.preserve,
  )..addListener(_onProgress);
  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  )..addStatusListener(_onFadeStatus);
  late final Animation<double> _splashOpacity = _fadeController.drive(
    Tween<double>(begin: 1, end: 0).chain(CurveTween(curve: Curves.easeOut)),
  );
  bool _scheduled = false;
  bool _homeMounted = false;
  bool _homeFrameReady = false;
  bool _transitionStarted = false;
  bool _overlayVisible = true;

  void _onArtworkReady() {
    if (_scheduled || !mounted) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.forward();
      _prepareHome();
    });
  }

  Future<void> _prepareHome() async {
    // Decode while the radar is running, not on the handoff frame.
    await Future.wait(
      widget.imagesToPrecache.map(
        (image) => precacheImage(
          image,
          context,
          onError: (Object error, StackTrace? stackTrace) {},
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _homeMounted = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _homeFrameReady = true;
      _onProgress();
    });
  }

  void _onProgress() {
    if (_controller.value < 1 || !_homeFrameReady || _transitionStarted) return;
    _transitionStarted = true;
    StartupDiagnostics.beginHandoff();
    // The existing home layer is revealed; no screen is built here.
    _fadeController.forward();
  }

  void _onFadeStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      StartupDiagnostics.endHandoff();
      setState(() => _overlayVisible = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: splashBackground,
    child: Stack(
      fit: StackFit.expand,
      children: [
        if (_homeMounted)
          RepaintBoundary(
            key: const ValueKey('startup-home-layer'),
            child: IgnorePointer(
              key: const ValueKey('startup-home-input'),
              ignoring: _overlayVisible,
              child: ExcludeSemantics(
                excluding: _overlayVisible,
                child: TickerMode(
                  enabled: !_overlayVisible,
                  child: widget.child,
                ),
              ),
            ),
          ),
        if (_overlayVisible)
          FadeTransition(
            key: const ValueKey('startup-overlay'),
            opacity: _splashOpacity,
            child: RepaintBoundary(
              child: AeroGazeSplashArt(
                key: const ValueKey('startup-art'),
                progress: _controller,
                onReady: _onArtworkReady,
              ),
            ),
          ),
      ],
    ),
  );
}

/// Keeps the supplied art as the base and repaints only radar and progress.
class AeroGazeSplashArt extends StatefulWidget {
  const AeroGazeSplashArt({
    this.onReady,
    this.progress = const AlwaysStoppedAnimation<double>(0),
    super.key,
  });
  final VoidCallback? onReady;
  final Animation<double> progress;

  @override
  State<AeroGazeSplashArt> createState() => _AeroGazeSplashArtState();
}

class _AeroGazeSplashArtState extends State<AeroGazeSplashArt> {
  ImageStream? _stream;
  ImageInfo? _info;
  bool _failed = false;
  late final ImageStreamListener _listener = ImageStreamListener(
    (info, _) {
      if (!mounted) return;
      setState(() {
        _info?.dispose();
        _info = info.clone();
      });
      widget.onReady?.call();
    },
    onError: (Object error, StackTrace? stackTrace) {
      if (!mounted) return;
      setState(() => _failed = true);
      widget.onReady?.call();
    },
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stream = const AssetImage(
      'assets/branding/aerogaze-splash.png',
    ).resolve(createLocalImageConfiguration(context));
    if (_stream?.key == stream.key) return;
    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _info?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
      statusBarColor: splashBackground,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: splashBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
    child: ColoredBox(
      color: splashBackground,
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: widget.progress,
          builder: (context, _) => Semantics(
            label: 'AeroGaze AI. Inicializando o aplicativo.',
            value: '${(widget.progress.value * 100).round()}%',
            child: _failed
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'AEROGAZE AI',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            color: Color(0xFF9BF59A),
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 180,
                          child: LinearProgressIndicator(
                            value: widget.progress.value,
                          ),
                        ),
                      ],
                    ),
                  )
                : CustomPaint(
                    key: const ValueKey('splash-canvas'),
                    painter: RadarSplashPainter(
                      image: _info?.image,
                      progress: widget.progress,
                    ),
                    child: const SizedBox.expand(),
                  ),
          ),
        ),
      ),
    ),
  );
}

class RadarSplashPainter extends CustomPainter {
  RadarSplashPainter({required this.image, required this.progress})
    : super(repaint: progress);
  final ui.Image? image;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;
    const original = Size(1080, 1920);
    final fitted = applyBoxFit(BoxFit.contain, original, size);
    final target = Alignment.center.inscribe(
      fitted.destination,
      Offset.zero & size,
    );
    canvas.save();
    canvas.translate(target.left, target.top);
    canvas.scale(target.width / original.width);
    final imagePaint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImageRect(
      image!,
      Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
      Offset.zero & original,
      imagePaint,
    );

    final value = progress.value.clamp(0.0, 1.0);
    final turns = value * 2;
    const radius = 450.0;
    final disk = Rect.fromCircle(center: radarCenter, radius: radius);
    // Opaque base removes the sweep and highlighted point baked into the PNG.
    canvas.drawCircle(
      radarCenter,
      radius + 4,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF203225), Color(0xFF19291D), Color(0xFF142219)],
          stops: [0, .7, 1],
        ).createShader(disk),
    );

    final angle = -math.pi / 2 + turns * math.pi * 2;
    for (var band = 0; band < 3; band++) {
      final start = angle - math.pi / 3 + band * math.pi / 9;
      final sector = Path()
        ..moveTo(radarCenter.dx, radarCenter.dy)
        ..arcTo(disk, start, math.pi / 9, false)
        ..close();
      canvas.drawPath(
        sector,
        Paint()
          ..color = const Color(
            0xFF9BF59A,
          ).withValues(alpha: [.07, .13, .23][band]),
      );
    }

    final grid = Paint()
      ..color = const Color(0xFF39573A)
      ..strokeWidth = 3;
    canvas.drawLine(
      radarCenter - const Offset(radius, 0),
      radarCenter + const Offset(radius, 0),
      grid,
    );
    canvas.drawLine(
      radarCenter - const Offset(0, radius),
      radarCenter + const Offset(0, radius),
      grid,
    );
    for (final entry in [
      (450.0, 6.0, 0xFF538452),
      (350.0, 4.0, 0xFF416742),
      (264.0, 4.0, 0xFF385B3A),
    ]) {
      canvas.drawCircle(
        radarCenter,
        entry.$1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = entry.$2
          ..color = Color(entry.$3),
      );
    }
    canvas.drawLine(
      radarCenter,
      radarCenter + Offset(math.cos(angle), math.sin(angle)) * radius,
      Paint()
        ..color = const Color(0xFF9BF59A)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );

    for (final contact in radarContacts) {
      final strength = contact.activityAt(turns);
      if (strength > 0) {
        canvas.drawCircle(
          contact.position,
          53,
          Paint()
            ..shader =
                RadialGradient(
                  colors: [
                    const Color(0xFF7FE3F5).withValues(alpha: strength * .2),
                    const Color(0x007FE3F5),
                  ],
                ).createShader(
                  Rect.fromCircle(center: contact.position, radius: 53),
                ),
        );
        for (final ring in [(28.0, 4.0, .65), (48.0, 3.0, .42)]) {
          canvas.drawCircle(
            contact.position,
            ring.$1,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = ring.$2
              ..color = const Color(
                0xFF7FE3F5,
              ).withValues(alpha: strength * ring.$3),
          );
        }
      }
      canvas.drawCircle(
        contact.position,
        8 + strength * 4,
        Paint()
          ..color = const Color(
            0xFF7FE3F5,
          ).withValues(alpha: .55 + strength * .45),
      );
    }

    // Restore the untouched central logo over the moving radar, with rounded clipping.
    const logo = Rect.fromLTWH(346, 646, 388, 388);
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(logo, const Radius.circular(86)));
    canvas.drawImageRect(image!, logo, logo, imagePaint);
    canvas.restore();

    // Clean background from the same artwork replaces its pre-painted partial bar.
    canvas.drawImageRect(
      image!,
      const Rect.fromLTWH(330, 1648, 420, 24),
      const Rect.fromLTWH(330, 1677, 420, 24),
      imagePaint,
    );
    const track = Rect.fromLTWH(340, 1684, 400, 10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(track, const Radius.circular(5)),
      Paint()..color = const Color(0xFF1F2A24),
    );
    if (value > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(340, 1684, 400 * value, 10),
          const Radius.circular(5),
        ),
        Paint()..color = const Color(0xFF9BF59A),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(RadarSplashPainter oldDelegate) =>
      image != oldDelegate.image || progress != oldDelegate.progress;
}
