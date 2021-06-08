import 'package:chillyflix/Widgets/virtual_keyboard/text_key.dart';
import 'package:flutter/material.dart';

typedef CustomKey = TextKey Function(void Function() handler);

class VirtualKeyboard extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final List<List<String>>? customLayout;
  final CustomKey? backspaceKey;
  final CustomKey? spaceKey;
  final CustomKey? clearKey;
  final double? keyboardHeight;

  const VirtualKeyboard({
    Key? key,
    this.onChanged,
    this.controller,
    this.customLayout,
    this.backspaceKey,
    this.spaceKey,
    this.clearKey,
    this.keyboardHeight,
  }) : super(key: key);

  @override
  _VirtualKeyboardState createState() => _VirtualKeyboardState();
}

class _VirtualKeyboardState extends State<VirtualKeyboard> {
  TextEditingController? _controller;
  late final List<List<String>> _keyLayout;
  TextEditingController get _effectiveController =>
      widget.controller ?? _controller!;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.keyboardHeight ?? 170,
      color: Colors.transparent,
      child: Column(
        children: [
          for (final row in _keyLayout) _buildRow(row),
          _buildBottomRow(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _createLocalController();
    }
    _keyLayout = widget.customLayout ??
        const [
          ["A", "B", "C", "D", "E", "F", "G", "1", "2", "3"],
          ["H", "I", "J", "K", "L", "M", "N", "4", "5", "6"],
          ["O", "P", "Q", "R", "S", "T", "U", "7", "8", "9"],
          ["V", "W", "X", "Y", "Z", "-", "'", "&", "0", "@"]
        ];
  }

  Widget _buildRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: [
          for (final key in keys)
            TextKey(
              text: key,
              onTap: _textInputHandler,
            )
        ],
      ),
    );
  }

  Expanded _buildBottomRow() {
    return Expanded(
      child: Row(
        children: [
          widget.clearKey != null
              ? widget.clearKey!(_clearHandler)
              : TextKey(
                  text: 'Clear',
                  onTap: (_) => _clearHandler(),
                ),
          widget.spaceKey != null
              ? widget.spaceKey!(_spaceHandler)
              : TextKey(
                  flex: 2,
                  text: 'Space',
                  onTap: (_) => _spaceHandler(),
                ),
          widget.backspaceKey != null
              ? widget.backspaceKey!(_backspaceHandler)
              : TextKey(
                  icon: Icons.backspace,
                  onTap: (_) => _backspaceHandler(),
                )
        ],
      ),
    );
  }

  void _clearHandler() {
    _effectiveController.text = "";
    widget.onChanged?.call(_effectiveController.text);
  }

  void _backspaceHandler() {
    if (_effectiveController.text.length > 0) {
      _effectiveController.text = _effectiveController.text
          .substring(0, _effectiveController.text.length - 1);
    }
    widget.onChanged?.call(_effectiveController.text);
  }

  void _spaceHandler() {
    if (_effectiveController.text != "") {
      _effectiveController.text = _effectiveController.text.trim() + " ";
    }
    widget.onChanged?.call(_effectiveController.text);
  }

  void _textInputHandler(String? text) {
    if (text != null) {
      _effectiveController.text =
          _effectiveController.text + text.toLowerCase();
    }
    widget.onChanged?.call(_effectiveController.text);
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? TextEditingController()
        : TextEditingController.fromValue(value);
  }
}
