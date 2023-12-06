import 'dart:async';

import 'package:flutter/material.dart';

/// Flashing sized box:
/// 
/// Usage: Selection page -> Dropdown menu widget
/// Event: Appears when user presses continue button without valid dropdown selection(s).
class FlashingBox extends StatefulWidget {
  const FlashingBox({Key? key, required this.width}) : super(key : key);
  
  final double? width;

  @override
  State<FlashingBox> createState() => FlashingBoxState();
}

class FlashingBoxState extends State<FlashingBox> {
  late bool _isRed;
  late Timer _timer;
  int _remainingTime = 4000; //time in miliseconds

  @override
  void initState() {
    super.initState();
    _isRed = false;
    _startFlashing();
  }

  void _startFlashing() {
    Duration duration = const Duration(milliseconds: 500);
    _timer = Timer.periodic(duration, (timer) {

      setState(() {
        if(_remainingTime > 0) {
          if(mounted) { 
            _isRed = !_isRed;
            _remainingTime -= 500; 
            }
        } else {
          // reset state
          if(mounted) { _isRed = false; }
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return SizedBox(
          width: widget.width,
          child: AnimatedContainer(
            duration: const Duration (milliseconds: 500),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _isRed ? Colors.red.withOpacity(0.7) : Colors.transparent,
              ),
          )
        );
      }
    );
  }
}