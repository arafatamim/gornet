import 'package:chillyflix/Widgets/virtual_keyboard/TextKey.dart';
import 'package:flutter/material.dart';

final List<String> row1 = ["A", "B", "C", "D", "E", "F", "G", "1", "2", "3"];
final List<String> row2 = ["H", "I", "J", "K", "L", "M", "N", "4", "5", "6"];
final List<String> row3 = ["O", "P", "Q", "R", "S", "T", "U", "7", "8", "9"];
final List<String> row4 = ["V", "W", "X", "Y", "Z", "-", "'", "&", "0", "@"];

class VirtualKeyboard extends StatefulWidget {
  VirtualKeyboard(
      {Key? key, this.onChanged, this.controller, this.restorationId})
      : super(key: key);

  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String? restorationId;

  @override
  _VirtualKeyboardState createState() => _VirtualKeyboardState();
}

class _VirtualKeyboardState extends State<VirtualKeyboard> {
  TextEditingController? _controller;
  TextEditingController get _effectiveController =>
      widget.controller ?? _controller!;

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? TextEditingController()
        : TextEditingController.fromValue(value);
  }

  void _textInputHandler(String? text) {
    if (text != null) {
      _effectiveController.text =
          _effectiveController.text + text.toLowerCase();
    }
    widget.onChanged?.call(_effectiveController.text);
  }

  void _backspaceHandler(_) {
    if (_effectiveController.text.length > 0) {
      _effectiveController.text = _effectiveController.text
          .substring(0, _effectiveController.text.length - 1);
    }
    widget.onChanged?.call(_effectiveController.text);
  }

  void _spaceHandler(_) {
    if (_effectiveController.text != "") {
      _effectiveController.text = _effectiveController.text.trim() + " ";
    }
    widget.onChanged?.call(_effectiveController.text);
  }

  void _clearHandler(_) {
    _effectiveController.text = "";
    widget.onChanged?.call(_effectiveController.text);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _createLocalController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      color: Colors.transparent,
      child: Column(
        // <-- Column
        children: [
          buildRowOne(), // <-- Row
          buildRowTwo(),
          buildRowThree(),
          buildRowFour(),
          buildRowFive(),
        ],
      ),
    );
  }

  Expanded buildRowOne() {
    return Expanded(
      child: Row(
        children: [
          for (final key in row1)
            TextKey(
              text: key,
              onTap: _textInputHandler,
            )
        ],
      ),
    );
  }

  Expanded buildRowTwo() {
    return Expanded(
      child: Row(
        children: [
          for (final key in row2)
            TextKey(
              text: key,
              onTap: _textInputHandler,
            )
        ],
      ),
    );
  }

  Expanded buildRowThree() {
    return Expanded(
      child: Row(
        children: [
          for (final key in row3)
            TextKey(
              text: key,
              onTap: _textInputHandler,
            )
        ],
      ),
    );
  }

  Expanded buildRowFour() {
    return Expanded(
      child: Row(
        children: [
          for (final key in row4)
            TextKey(
              text: key,
              onTap: _textInputHandler,
            )
        ],
      ),
    );
  }

  Expanded buildRowFive() {
    return Expanded(
      child: Row(
        children: [
          TextKey(
            text: 'Clear',
            onTap: _clearHandler,
          ),
          TextKey(
            text: 'Space',
            onTap: _spaceHandler,
          ),
          TextKey(
            icon: Icons.backspace,
            onTap: _backspaceHandler,
          )
        ],
      ),
    );
  }
}
