import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = '0';
  String _expression = '';
  double _num1 = 0;
  double _num2 = 0;
  String _operand = '';
  bool _justEvaluated = false;

  void _buttonPressed(String buttonText) {
    HapticFeedback.lightImpact(); // Provide feedback
    setState(() {
      if (buttonText == 'C') {
        _output = '0';
        _expression = '';
        _num1 = 0;
        _num2 = 0;
        _operand = '';
        _justEvaluated = false;
      } else if (buttonText == '+' ||
          buttonText == '-' ||
          buttonText == '×' ||
          buttonText == '÷') {
        _num1 = double.tryParse(_output) ?? 0;
        _operand = buttonText;
        _expression = '${_formatNum(_num1)} $buttonText';
        _justEvaluated = false;
        _output = '0';
      } else if (buttonText == '.') {
        if (_justEvaluated) {
          _output = '0.';
          _justEvaluated = false;
          return;
        }
        if (_output.contains('.')) return;
        _output = '$_output.';
      } else if (buttonText == '%') {
        double currentVal = double.tryParse(_output) ?? 0;
        if (_operand.isNotEmpty) {
          double percentageVal = _num1 * currentVal / 100;
          _output = _formatNum(percentageVal);
        } else {
          _output = _formatNum(currentVal / 100);
        }
        _justEvaluated = false;
      } else if (buttonText == '=') {
        _num2 = double.tryParse(_output) ?? 0;

        double result = 0;
        if (_operand == '+') result = _num1 + _num2;
        if (_operand == '-') result = _num1 - _num2;
        if (_operand == '×') result = _num1 * _num2;
        if (_operand == '÷') {
          if (_num2 == 0) {
            _output = 'Error';
            _expression = '';
            _operand = '';
            _num1 = 0;
            return;
          }
          result = _num1 / _num2;
        }

        _expression = '${_expression} ${_formatNum(_num2)} =';
        _output = _formatNum(result);
        _num1 = result;
        _num2 = 0;
        _operand = '';
        _justEvaluated = true;
      } else {
        if (_justEvaluated) {
          _output = buttonText;
          _justEvaluated = false;
          return;
        }
        if (_output == '0') {
          _output = buttonText;
        } else {
          if (_output.length < 12) {
            _output = _output + buttonText;
          }
        }
      }
    });
  }

  String _formatNum(double val) {
    if (val == val.truncateToDouble() && !val.isInfinite && !val.isNaN) {
      return val.toInt().toString();
    }
    String s = val.toStringAsFixed(6);
    s = s.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;
            return Column(
              children: [
                Container(
                  constraints: BoxConstraints(
                    minHeight: isLandscape ? 80 : (isWide ? 180 : 140),
                    maxHeight: isLandscape ? 120 : double.infinity,
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_expression.isNotEmpty)
                        Text(
                          _expression,
                          style: TextStyle(
                            fontSize: isLandscape ? 14 : 18,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.right,
                        ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          _output,
                          style: TextStyle(
                            fontSize: isLandscape ? 48 : (isWide ? 84 : 64),
                            fontWeight: FontWeight.w300,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + (isLandscape ? 20 : (isWide ? 40 : 80)),
                      ),
                      child: Container(
                        height: isLandscape ? 400 : null, // Fixed height in landscape to enable scrolling if needed
                        child: _buildKeypad(isDark, isWide),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeypad(bool isDark, bool isWide) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildRow([
            _btn('7', isDark: isDark, isWide: isWide),
            _btn('8', isDark: isDark, isWide: isWide),
            _btn('9', isDark: isDark, isWide: isWide),
            _btn('÷', isDark: isDark, isWide: isWide, type: _BtnType.operator),
          ]),
          _buildRow([
            _btn('4', isDark: isDark, isWide: isWide),
            _btn('5', isDark: isDark, isWide: isWide),
            _btn('6', isDark: isDark, isWide: isWide),
            _btn('×', isDark: isDark, isWide: isWide, type: _BtnType.operator),
          ]),
          _buildRow([
            _btn('1', isDark: isDark, isWide: isWide),
            _btn('2', isDark: isDark, isWide: isWide),
            _btn('3', isDark: isDark, isWide: isWide),
            _btn('-', isDark: isDark, isWide: isWide, type: _BtnType.operator),
          ]),
          _buildRow([
            _btn('.', isDark: isDark, isWide: isWide),
            _btn('0', isDark: isDark, isWide: isWide),
            _btn('%', isDark: isDark, isWide: isWide),
            _btn('C', isDark: isDark, isWide: isWide, type: _BtnType.clear),
          ]),
          _buildRow([
            _btn('+', isDark: isDark, isWide: isWide, type: _BtnType.operator),
            _btn('=', isDark: isDark, isWide: isWide, type: _BtnType.equal),
          ]),
        ],
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Expanded(child: Row(children: children));
  }

  Widget _btn(String label, {required bool isDark, required bool isWide, _BtnType type = _BtnType.number}) {
    Color bgColor;
    Color txtColor;

    switch (type) {
      case _BtnType.operator:
        bgColor = isDark
            ? const Color(0xFF4F46E5).withOpacity(0.3)
            : const Color(0xFF4F46E5).withOpacity(0.1);
        txtColor = isDark ? const Color(0xFFD946EF) : const Color(0xFF4F46E5);
        break;
      case _BtnType.equal:
        bgColor = isDark ? const Color(0xFFD946EF) : const Color(0xFF4F46E5);
        txtColor = Colors.white;
        break;
      case _BtnType.clear:
        bgColor = isDark
            ? Colors.red.withOpacity(0.2)
            : Colors.red.shade50;
        txtColor = Colors.red;
        break;
      case _BtnType.number:
      default:
        bgColor = isDark ? const Color(0xFF1E293B) : Colors.grey.shade100;
        txtColor = isDark ? Colors.white : const Color(0xFF1E293B);
        break;
    }

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _buttonPressed(label),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (type == _BtnType.equal)
                BoxShadow(
                  color: (isDark ? const Color(0xFFD946EF) : const Color(0xFF4F46E5)).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isWide ? 32 : 28,
              fontWeight: FontWeight.w600,
              color: txtColor,
            ),
          ),
        ),
      ),
    );
  }
}

enum _BtnType { number, operator, equal, clear }

