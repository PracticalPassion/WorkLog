// overlay_component.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomOverlay extends StatelessWidget {
  final FocusNode focusNode;
  final VoidCallback onCompleted;

  const CustomOverlay({Key? key, required this.focusNode, required this.onCompleted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: CupertinoColors.activeBlue,
            child: Text('Fertig'),
            onPressed: onCompleted,
          ),
        ],
      ),
    );
  }
}

class DurationInputField extends StatefulWidget {
  final Duration initialDuration;
  final Function(Duration) onDurationChanged;

  const DurationInputField({
    Key? key,
    required this.initialDuration,
    required this.onDurationChanged,
  }) : super(key: key);

  @override
  _DurationInputFieldState createState() => _DurationInputFieldState();
}

class _DurationInputFieldState extends State<DurationInputField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: (widget.initialDuration.inMinutes / 60).toStringAsFixed(1));

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height - MediaQuery.of(context).viewInsets.bottom - 50,
        right: offset.dx,
        child: CustomOverlay(
          focusNode: _focusNode,
          onCompleted: () => _focusNode.unfocus(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(() {});
    _controller.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      focusNode: _focusNode,
      controller: _controller,
      maxLength: 5,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onEditingComplete: () {
        double hours = double.tryParse(_controller.text) ?? 0.0;
        Duration newDuration = Duration(minutes: (hours * 60).round());
        widget.onDurationChanged(newDuration);
      },
    );
  }
}
