import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Renders only a photographic region of a supplied reference, never its UI.
/// Replace these regions with original source photos when available.
class ReferencePhoto extends StatefulWidget {
  const ReferencePhoto({
    required this.asset,
    required this.region,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String asset;
  final Rect region;
  final BoxFit fit;

  @override
  State<ReferencePhoto> createState() => _ReferencePhotoState();
}

class _ReferencePhotoState extends State<ReferencePhoto> {
  ImageStream? _stream;
  ImageInfo? _info;
  late final ImageStreamListener _listener = ImageStreamListener((info, _) {
    if (!mounted) return;
    setState(() {
      _info?.dispose();
      _info = info.clone();
    });
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(ReferencePhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) _resolve();
  }

  void _resolve() {
    final stream = AssetImage(
      widget.asset,
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
  Widget build(BuildContext context) => CustomPaint(
    painter: _PhotoPainter(_info?.image, widget.region, widget.fit),
    size: Size.infinite,
  );
}

class _PhotoPainter extends CustomPainter {
  _PhotoPainter(this.image, this.region, this.fit);

  final ui.Image? image;
  final Rect region;
  final BoxFit fit;

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;
    final fitted = applyBoxFit(fit, region.size, size);
    final source = Alignment.center.inscribe(fitted.source, region);
    final target = Alignment.center.inscribe(
      fitted.destination,
      Offset.zero & size,
    );
    canvas.drawImageRect(
      image!,
      source,
      target,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(_PhotoPainter oldDelegate) =>
      image != oldDelegate.image ||
      region != oldDelegate.region ||
      fit != oldDelegate.fit;
}
