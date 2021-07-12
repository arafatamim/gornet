import 'package:goribernetflix/Widgets/virtual_keyboard/text_key.dart';
import 'package:flutter/material.dart';

typedef CustomKey = TextKey Function(void Function() defaultHandler);

class VirtualKeyboard extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final List<List<String>>? customLayout;
  final List<List<TextKey>>? customBottomRows;
  final CustomKey? backspaceKey;
  final CustomKey? spaceKey;
  final CustomKey? clearKey;
  final double? keyboardHeight;
  final String? Function(String? incomingValue)? textTransformer;

  const VirtualKeyboard({
    Key? key,
    this.onChanged,
    this.controller,
    this.customLayout,
    this.customBottomRows,
    this.backspaceKey,
    this.spaceKey,
    this.clearKey,
    this.keyboardHeight,
    this.textTransformer,
  }) : super(key: key);

  @override
  _VirtualKeyboardState createState() => _VirtualKeyboardState();
}

class _VirtualKeyboardState extends State<VirtualKeyboard> {
  TextEditingController? _controller;
  late final List<List<String>> _keyLayout;

  TextEditingController get effectiveController =>
      widget.controller ?? _controller!;

  void onChangedCallback() => widget.onChanged?.call(effectiveController.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.keyboardHeight ?? 170,
      color: Colors.transparent,
      child: Column(
        children: [
          for (final row in _keyLayout) _buildRowOfStrings(row),
          if (widget.customBottomRows != null)
            for (final row in widget.customBottomRows!) _buildRowOfWidgets(row)
          else
            _buildDefaultBottomRow(),
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
    if (widget.controller == null) _createLocalController();

    _keyLayout = widget.customLayout ??
        const [
          ["A", "B", "C", "D", "E", "F", "G", "1", "2", "3"],
          ["H", "I", "J", "K", "L", "M", "N", "4", "5", "6"],
          ["O", "P", "Q", "R", "S", "T", "U", "7", "8", "9"],
          ["V", "W", "X", "Y", "Z", "-", "'", "&", "0", "@"]
        ];
  }

  Widget _buildRowOfStrings(List<String> keys) {
    return _buildRowOfWidgets(keys
        .map((key) => TextKey(
              text: key,
              onTap: _textInputHandler,
            ))
        .toList());
    // return Expanded(
    //   child: Row(
    //     children: [
    //       for (final key in keys)
    //         TextKey(
    //           text: key,
    //           onTap: _textInputHandler,
    //         )
    //     ],
    //   ),
    // );
  }

  Widget _buildRowOfWidgets(List<TextKey> keys) {
    return Expanded(
      child: Row(
        children: [for (final key in keys) key],
      ),
    );
  }

  Expanded _buildDefaultBottomRow() {
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
    effectiveController.text = "";
    onChangedCallback();
  }

  void _backspaceHandler() {
    if (effectiveController.text.length > 0) {
      effectiveController.text = effectiveController.text
          .substring(0, effectiveController.text.length - 1);
    }
    onChangedCallback();
  }

  void _spaceHandler() {
    if (effectiveController.text != "") {
      effectiveController.text = effectiveController.text.trim() + " ";
    }
    onChangedCallback();
  }

  void _textInputHandler(String? text) {
    if (text != null) {
      if (widget.textTransformer != null)
        effectiveController.text =
            effectiveController.text + widget.textTransformer!(text)!;
      else
        effectiveController.text = effectiveController.text + text;
    }
    onChangedCallback();
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? TextEditingController()
        : TextEditingController.fromValue(value);
  }
}
