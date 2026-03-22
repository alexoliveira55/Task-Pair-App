import 'package:flutter/material.dart';
import '../../../../shared/themes/app_colors.dart';

class ThermometerWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int currentPoints;
  final int targetPoints;
  final double height;
  final double width;

  const ThermometerWidget({
    super.key,
    required this.progress,
    required this.currentPoints,
    required this.targetPoints,
    this.height = 200,
    this.width = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          width: width,
          child: CustomPaint(
            painter: _ThermometerPainter(progress: progress.clamp(0.0, 1.0)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$currentPoints / $targetPoints',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          '${(progress * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _ThermometerPainter extends CustomPainter {
  final double progress;

  _ThermometerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final bulbRadius = size.width / 2;
    final tubeWidth = size.width * 0.4;
    final tubeLeft = (size.width - tubeWidth) / 2;
    final tubeTop = 0.0;
    final tubeBottom = size.height - bulbRadius;
    final tubeHeight = tubeBottom - tubeTop;

    final borderPaint = Paint()
      ..color = AppColors.thermometerBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final backgroundPaint = Paint()
      ..color = AppColors.thermometerBackground
      ..style = PaintingStyle.fill;

    final fillPaint = Paint()
      ..color = AppColors.thermometerFill
      ..style = PaintingStyle.fill;

    // Draw tube background
    final tubeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tubeLeft, tubeTop, tubeWidth, tubeHeight),
      Radius.circular(tubeWidth / 2),
    );
    canvas.drawRRect(tubeRect, backgroundPaint);

    // Draw fill
    final fillHeight = tubeHeight * progress;
    final fillTop = tubeBottom - fillHeight;
    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tubeLeft, fillTop, tubeWidth, fillHeight),
      Radius.circular(tubeWidth / 2),
    );
    canvas.drawRRect(fillRect, fillPaint);

    // Draw tube border
    canvas.drawRRect(tubeRect, borderPaint);

    // Draw bulb background
    canvas.drawCircle(
      Offset(size.width / 2, size.height - bulbRadius),
      bulbRadius,
      backgroundPaint,
    );

    // Draw bulb fill (always red)
    canvas.drawCircle(
      Offset(size.width / 2, size.height - bulbRadius),
      bulbRadius * 0.85,
      fillPaint,
    );

    // Draw bulb border
    canvas.drawCircle(
      Offset(size.width / 2, size.height - bulbRadius),
      bulbRadius,
      borderPaint,
    );

    // Draw tick marks
    final tickPaint = Paint()
      ..color = AppColors.thermometerBorder
      ..strokeWidth = 1;
    const tickCount = 10;
    for (int i = 0; i <= tickCount; i++) {
      final y = tubeBottom - (tubeHeight * i / tickCount);
      final tickLength = i % 5 == 0 ? 8.0 : 4.0;
      canvas.drawLine(
        Offset(tubeLeft - tickLength, y),
        Offset(tubeLeft, y),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ThermometerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
