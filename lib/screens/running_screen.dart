import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/user_profile.dart';
import '../services/activity_service.dart';
import '../theme/app_theme.dart';

/// Full-screen "Active Mode": a looping background video with a live
/// metrics overlay (distance, pace, calories). Automatically shown when
/// ActivityService detects a run; can also be entered manually via swipe.
class RunningScreen extends StatefulWidget {
  final UserProfile profile;
  const RunningScreen({super.key, required this.profile});

  @override
  State<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  VideoPlayerController? _videoController;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    // Bundled looping runner-POV / treadmill style background video.
    // Swap this asset path for your own footage; keep it silent/ambient.
    final controller = VideoPlayerController.asset('assets/videos/running_loop.mp4');
    try {
      await controller.initialize();
      controller
        ..setLooping(true)
        ..setVolume(0)
        ..play();
      if (mounted) {
        setState(() {
          _videoController = controller;
          _videoReady = true;
        });
      }
    } catch (_) {
      // If the asset is missing (e.g. not yet supplied by the developer),
      // fall back gracefully to a solid gradient background below.
      if (mounted) setState(() => _videoReady = false);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activity = context.watch<ActivityService>();
    final distanceKm = activity.totalDistanceMeters / 1000;
    final calories = distanceKm * widget.profile.caloriesPerKm;
    final pace = activity.paceMinPerKm;
    final elapsed = activity.sessionStart == null
        ? Duration.zero
        : DateTime.now().difference(activity.sessionStart!);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_videoReady && _videoController != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            )
          else
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.deepBlue, AppColors.voidBlack, AppColors.emberRed],
                ),
              ),
            ),
          // Darkening scrim so overlay text stays legible over any footage.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent, Colors.black87],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _LivePill(state: activity.state),
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Distance',
                          value: '${distanceKm.toStringAsFixed(2)} km',
                        ),
                      ),
                      Expanded(
                        child: _MetricTile(
                          label: 'Pace',
                          value: pace > 0
                              ? '${pace.toStringAsFixed(1)} /km'
                              : '--',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Calories',
                          value: calories.toStringAsFixed(0),
                        ),
                      ),
                      Expanded(
                        child: _MetricTile(
                          label: 'Time',
                          value: _formatDuration(elapsed),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _LivePill extends StatelessWidget {
  final ActivityState state;
  const _LivePill({required this.state});

  @override
  Widget build(BuildContext context) {
    final label = switch (state) {
      ActivityState.running => 'RUNNING',
      ActivityState.walking => 'WALKING',
      ActivityState.idle => 'STANDBY',
    };
    final color = switch (state) {
      ActivityState.running => AppColors.pulseRed,
      ActivityState.walking => AppColors.electricBlue,
      ActivityState.idle => Colors.white54,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
