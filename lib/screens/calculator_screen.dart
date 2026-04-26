import 'package:flutter/material.dart';
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
  bool _justEvaluated = false; // Track if = was just pressed

  void _buttonPressed(String buttonText) {
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
        // Contextual percentage:
        // If an operator is pending: e.g. 100 + 20% → 100 + (100 * 20/100) = 120
        // If no operator: e.g. 200% → 2 (standalone /100)
        double currentVal = double.tryParse(_output) ?? 0;
        if (_operand.isNotEmpty) {
          // e.g. num1=100, operand=+, currentVal=20 → percentage = 100 * 20/100 = 20
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
        // Number input
        if (_justEvaluated) {
          _output = buttonText;
          _justEvaluated = false;
          return;
        }
        if (_output == '0') {
          _output = buttonText;
        } else {
          // Limit display length
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
    // Limit decimal places to 6
    String s = val.toStringAsFixed(6);
    // Remove trailing zeros
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
        title: const Text('Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── DISPLAY AREA ─────────────────────────────────
            Container(
              constraints: const BoxConstraints(minHeight: 140),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Expression (history) line
                  if (_expression.isNotEmpty)
                    Text(
                      _expression,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  const SizedBox(height: 4),
                  // Main output number
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _output,
                      style: TextStyle(
                        fontSize: isWide ? 72 : 60,
                        fontWeight: FontWeight.w300,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // ── KEYPAD ───────────────────────────────────────
            Expanded(
              child: Padding(
                // Extra bottom padding so buttons don't hide under floating NavBar
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 90,
                ),
                child: _buildKeypad(isDark, isWide),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(bool isDark, bool isWide) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Row 1: 7 8 9 ÷
          _buildRow([
            _btn('7', isDark: isDark, isWide: isWide),
            _btn('8', isDark: isDark, isWide: isWide),
            _btn('9', isDark: isDark, isWide: isWide),
            _btn('÷', isDark: isDark, isWide: isWide, type: _BtnType.operator),
          ]),
          // Row 2: 4 5 6 ×
          _buildRow([
            _btn('4', isDark: isDark, isWide: isWide),
            _btn('5', isDark: isDark, isWide: isWide),
            _btn('6', isDark: isDark, isWide: isWide),
            _btn('×', isDark: isDark, isWide: isWide, type: _BtnType.operator),
          ]),
          // Row 3: 1 2 3 -
          _buildRow([
            _btn('1', isDark: isDark, isWide: isWide),
            _btn('2', isDark: isDark, isWide: isWide),
            _btn('3', isDark: isDark, isWide: isWide),
            _btn('-', isDark: isDark, isWide: isWide, type: _BtnType.operator),
          ]),
          // Row 4: . 0 % C
          _buildRow([
            _btn('.', isDark: isDark, isWide: isWide),
            _btn('0', isDark: isDark, isWide: isWide),
            _btn('%', isDark: isDark, isWide: isWide),
            _btn('C', isDark: isDark, isWide: isWide, type: _BtnType.clear),
          ]),
          // Row 5: + =
          _buildRow([
            _btn('+', isDark: isDark, isWide: isWide, type: _BtnType.operator),
            _btn('=', isDark: isDark, isWide: isWide, type: _BtnType.equal),
          ]),
        ],
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(children: children);
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
      child: Container(
        margin: const EdgeInsets.all(6),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => _buttonPressed(label),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: isWide ? 80 : 70,
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: txtColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _BtnType { number, operator, equal, clear }
