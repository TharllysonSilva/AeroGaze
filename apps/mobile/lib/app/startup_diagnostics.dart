import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Opt-in physical-device measurements; compiled out of ordinary builds.
abstract final class StartupDiagnostics {
  static const enabled = bool.fromEnvironment('TRACE_STARTUP');
  static final List<FrameTiming> _frames = [];
  static int? _start;
  static int? _end;

  static void attach() {
    if (!enabled) return;
    SchedulerBinding.instance.addTimingsCallback(_record);
  }

  static void _record(List<FrameTiming> frames) => _frames.addAll(frames);

  static void beginHandoff() {
    if (!enabled) return;
    _start =
        SchedulerBinding.instance.currentSystemFrameTimeStamp.inMicroseconds;
  }

  static void endHandoff() {
    if (!enabled) return;
    _end = SchedulerBinding.instance.currentSystemFrameTimeStamp.inMicroseconds;
    Timer(const Duration(milliseconds: 1500), _report);
  }

  static void _report() {
    SchedulerBinding.instance.removeTimingsCallback(_record);
    final hz = PlatformDispatcher.instance.views.first.display.refreshRate;
    final budget = hz > 0 ? 1000 / hz : 1000 / 60;
    final selected = _frames.where((frame) {
      final timestamp = frame.timestampInMicroseconds(FramePhase.vsyncStart);
      return _start != null &&
          _end != null &&
          timestamp >= _start! &&
          timestamp <= _end! + 50000;
    }).toList();
    final build = selected
        .map((frame) => frame.buildDuration.inMicroseconds / 1000)
        .toList();
    final raster = selected
        .map((frame) => frame.rasterDuration.inMicroseconds / 1000)
        .toList();
    double maximum(List<double> values) =>
        values.fold(0, (a, b) => a > b ? a : b);
    debugPrint(
      'AEROGAZE_STARTUP_PROFILE ${jsonEncode({'frames': selected.length, 'displayHz': hz, 'frameBudgetMs': budget, 'maxBuildMs': maximum(build), 'maxRasterMs': maximum(raster), 'slowBuildFrames': build.where((value) => value > budget).length, 'slowRasterFrames': raster.where((value) => value > budget).length})}',
    );
    _frames.clear();
  }
}
