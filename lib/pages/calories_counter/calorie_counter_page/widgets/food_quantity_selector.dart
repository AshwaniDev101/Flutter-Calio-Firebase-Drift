import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../helper/progress_visuals_helper.dart';

class FoodQuantitySelector extends StatefulWidget {
  final double initialValue;
  final double min;
  final double max;
  final double step;
  final int precision;
  final void Function(double oldValue, double newValue)? onChanged;
  final double buttonSize;
  final Color? buttonColor;
  final bool enableHoldToRepeat;

  const FoodQuantitySelector({
    super.key,
    required this.initialValue,
    this.min = 0.0,
    this.max = 100,
    this.step = 1.0,
    this.precision = 0,
    this.onChanged,
    this.buttonSize = 28.0,
    this.buttonColor = Colors.grey,
    this.enableHoldToRepeat = true,
  })  : assert(min <= max),
        assert(precision >= 0);

  @override
  State<FoodQuantitySelector> createState() => _FoodQuantitySelectorState();
}

class _FoodQuantitySelectorState extends State<FoodQuantitySelector> {
  late double _value;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _value = _clamp(widget.initialValue);
    _controller = TextEditingController(text: _format(_value));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant FoodQuantitySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _setValue(widget.initialValue, notify: false);
    }
  }

  double _clamp(double v) => v.isNaN ? widget.min : v.clamp(widget.min, widget.max);

  String _format(double v) => trimTrailingZero(v);

  void _setValue(double v, {bool notify = true}) {
    final next = _clamp(v);
    if ((next - _value).abs() > (1e-12)) {
      final old = _value; // store old value
      setState(() {
        _value = next;
        _controller.text = _format(_value);
      });
      if (notify) widget.onChanged?.call(old, next);
    } else {
      _controller.text = _format(_value);
    }
  }

  void _changeBy(double delta, {bool notify = true}) {
    _setValue((_value + delta), notify: notify);
  }

  void _stopAutoRepeat() {
    _autoTimer?.cancel();
    _autoTimer = null;
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _commitTextField();
    } else {
      _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    }
  }

  void _commitTextField() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      _controller.text = _format(_value);
      return;
    }

    final normalized = raw.replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null) {
      _controller.text = _format(_value);
      return;
    }

    _setValue(parsed, notify: true);
  }

  @override
  void dispose() {
    _stopAutoRepeat();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final iconColor = Colors.grey.shade500;
    final backgroundColor = Colors.grey.shade200;
    final activeButtonColor = Colors.greenAccent.shade400;
    final activeIconColor = Colors.white;

    return Semantics(
      label: 'Quantity selector',
      value: _format(_value),
      increasedValue: _format(_clamp(_value + widget.step)),
      decreasedValue: _format(_clamp(_value - widget.step)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularIconButton(
            icon: Icons.remove,
            backgroundColor: backgroundColor,
            iconColor: iconColor,
            onTap: () => _changeBy(-widget.step),
          ),
          const SizedBox(width: 1),
          SizedBox(
            width: 30,
            height: 30,
            child: TextField(
              enabled: false,
              // remove this to enable editing
              style: TextStyle(
                color: widget.initialValue > 0 ? Colors.grey : Colors.grey,
                fontSize: 14.0,
                fontWeight: widget.initialValue > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[\d\-,.]*$')),
              ],
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
              onSubmitted: (_) => _commitTextField(),
            ),
          ),
          const SizedBox(width: 1),
          CircularIconButton(
            icon: Icons.add,
            backgroundColor: _value > 0 ? activeButtonColor : backgroundColor,
            iconColor: _value > 0 ? activeIconColor : iconColor,
            onTap: () => _changeBy(widget.step),
          ),
        ],
      ),
    );
  }
}

class CircularIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final double size;

  const CircularIconButton({
    super.key,
    required this.onTap,
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(icon, color: iconColor, size: size),
          ),
        ),
      ),
    );
  }
}
