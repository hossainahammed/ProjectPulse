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
  String _operand = '';
  bool _justEvaluated = false;
  List<String> _history = [];
  bool _showHistory = false;

  void _buttonPressed(String btnText) {
    HapticFeedback.lightImpact();
    setState(() {
      if (btnText == 'AC') {
        _output = '0';
        _expression = '';
        _num1 = 0;
        _operand = '';
        _justEvaluated = false;
      } else if (btnText == '⌫') {
        if (_output == 'Error') {
          _output = '0';
        } else if (_output.length > 1) {
          _output = _output.substring(0, _output.length - 1);
        } else {
          _output = '0';
        }
      } else if (['+', '-', '×', '÷'].contains(btnText)) {
        if (_output == 'Error') {
          _output = '0';
        }
        if (_operand.isNotEmpty && !_justEvaluated) {
          double num2 = double.tryParse(_output) ?? 0;
          double result = 0;
          if (_operand == '+') result = _num1 + num2;
          if (_operand == '-') result = _num1 - num2;
          if (_operand == '×') result = _num1 * num2;
          if (_operand == '÷') {
            if (num2 == 0) {
              _output = 'Error';
              _expression = '';
              _operand = '';
              _num1 = 0;
              _justEvaluated = true;
              return;
            }
            result = _num1 / num2;
          }
          _num1 = result;
        } else if (_operand.isEmpty) {
          _num1 = double.tryParse(_output) ?? 0;
        }
        _operand = btnText;
        _expression = '${_formatNum(_num1)} $btnText';
        _output = _formatNum(_num1);
        _justEvaluated = true;
      } else if (btnText == '=') {
        if (_output == 'Error') return;
        double num2 = double.tryParse(_output) ?? 0;
        double result = 0;

        if (_operand == '+') result = _num1 + num2;
        if (_operand == '-') result = _num1 - num2;
        if (_operand == '×') result = _num1 * num2;
        if (_operand == '÷') {
          if (num2 == 0) {
            _output = 'Error';
            _expression = '';
            _operand = '';
            _num1 = 0;
            _justEvaluated = true;
            return;
          }
          result = _num1 / num2;
        }

        if (_operand.isNotEmpty) {
          final fullExpr =
              '$_expression ${_formatNum(num2)} = ${_formatNum(result)}';
          _history.insert(0, fullExpr);
          _output = _formatNum(result);
          _expression = '';
          _operand = '';
          _justEvaluated = true;
        }
      } else if (btnText == '%') {
        if (_output == 'Error') return;
        double val = double.tryParse(_output) ?? 0;
        if (_operand == '+' || _operand == '-') {
          _output = _formatNum(_num1 * (val / 100));
        } else {
          _output = _formatNum(val / 100);
        }
      } else if (btnText == '.') {
        if (_output == 'Error') {
          _output = '0.';
          _justEvaluated = false;
        } else if (!_output.contains('.')) {
          _output += '.';
        }
      } else {
        if (_output == '0' || _output == 'Error' || _justEvaluated) {
          _output = btnText;
          _justEvaluated = false;
        } else {
          if (_output.length < 12) _output += btnText;
        }
      }
    });
  }

  String _formatNum(double val) {
    if (val.isInfinite || val.isNaN) return 'Error';
    if (val == val.toInt()) return val.toInt().toString();
    String s = val.toString();
    if (s.length > 10) s = val.toStringAsPrecision(7);
    return s.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF02020B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Assistant Calculator',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(_showHistory ? Icons.calculate_outlined : Icons.history_rounded, color: textColor),
            onPressed: () => setState(() => _showHistory = !_showHistory),
          ),
        ],
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;
            
            if (isLandscape) {
              return Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: _showHistory ? _buildHistoryPanel(isDark) : _buildDisplay(isDark, true),
                  ),
                  const VerticalDivider(width: 1, indent: 20, endIndent: 20),
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _buildKeypad(isDark, true),
                    ),
                  ),
                ],
              );
            }
            
            return Column(
              children: [
                Expanded(
                  flex: 2,
                  child: _showHistory ? _buildHistoryPanel(isDark) : _buildDisplay(isDark, false),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _buildKeypad(isDark, false),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDisplay(bool isDark, bool isLandscape) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _expression,
            style: TextStyle(
              fontSize: isLandscape ? 16 : 18,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: isLandscape ? 4 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _output,
              style: TextStyle(
                fontSize: isLandscape ? 50 : 72,
                fontWeight: FontWeight.w300,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _history.clear()),
                child: const Text('Clear', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          Expanded(
            child: _history.isEmpty
                ? const Center(child: Text('No history', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _history[index],
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(bool isDark, bool isLandscape) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, isLandscape ? 16 : 8, 16, 16),
      child: Column(
        children: [
          _buildRow(['AC', '⌫', '%', '÷'], isDark, isLandscape),
          _buildRow(['7', '8', '9', '×'], isDark, isLandscape),
          _buildRow(['4', '5', '6', '-'], isDark, isLandscape),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildRow(['1', '2', '3'], isDark, isLandscape),
                    _buildRow(['0', '.', '='], isDark, isLandscape),
                  ],
                ),
              ),
              _buildButton('+', isDark, isTall: true, isLandscape: isLandscape),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> labels, bool isDark, bool isLandscape) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: labels.map<Widget>((label) => _buildButton(label, isDark, isLandscape: isLandscape)).toList(),
      ),
    );
  }

  Widget _buildButton(String label, bool isDark, {bool isTall = false, required bool isLandscape}) {
    bool isOp = ['÷', '×', '-', '+', '='].contains(label);
    bool isControl = ['AC', '⌫', '%'].contains(label);
    bool isEq = label == '=';
    
    Color bgColor;
    Color txtColor;

    if (isDark) {
      bgColor = isEq ? const Color(0xFFD946EF) : (isOp || isControl ? const Color(0xFF16162D) : const Color(0xFF1B1B2F));
      txtColor = isEq ? Colors.white : (isOp || isControl ? const Color(0xFFA855F7) : Colors.white);
      if (label == 'AC') txtColor = Colors.red[800]!;
    } else {
      bgColor = isEq ? const Color(0xFF6366F1) : (isOp || isControl ? const Color(0xFFF0F5FF) : const Color(0xFFF9FAFB));
      txtColor = isEq ? Colors.white : (isOp || isControl ? const Color(0xFF6366F1) : Colors.black87);
      if (label == 'AC') txtColor = Colors.red[400]!;
    }

    final double height = isLandscape ? 44 : 56;
    final double tallHeight = isLandscape ? 96 : 122;

    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: InkWell(
          onTap: () => _buttonPressed(label),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: isTall ? tallHeight : height,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: label == '⌫' 
              ? Icon(Icons.backspace_outlined, color: txtColor, size: isLandscape ? 18 : 20)
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: isLandscape ? 18 : 20,
                    fontWeight: isOp ? FontWeight.bold : FontWeight.w500,
                    color: txtColor,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
