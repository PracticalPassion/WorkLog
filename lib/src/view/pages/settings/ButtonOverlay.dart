import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NumberInputWithDoneButton extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final Function(String) onCompleted;

  NumberInputWithDoneButton({required this.controller, required this.placeholder, required this.onCompleted});

  @override
  _NumberInputWithDoneButtonState createState() => _NumberInputWithDoneButtonState();
}

class _NumberInputWithDoneButtonState extends State<NumberInputWithDoneButton> {
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context)?.insert(_overlayEntry!);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom + 10.0,
        right: 0,
        child: Container(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: CupertinoColors.activeBlue,
              onPressed: () {
                _focusNode.unfocus();
              },
              child: const Text('Fertig'),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      padding: const EdgeInsets.all(8),
      controller: widget.controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
      focusNode: _focusNode,
      maxLength: 5,
      textInputAction: TextInputAction.done,
      placeholder: widget.placeholder,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(5.0),
      ),
      onChanged: (value) {
        if (value.isNotEmpty) {
          widget.onCompleted(value.replaceAll(",", "."));
        }
      },
      onSubmitted: (_) {
        widget.onCompleted(widget.controller.text);
        _focusNode.unfocus();
      },
    );
  }
}
