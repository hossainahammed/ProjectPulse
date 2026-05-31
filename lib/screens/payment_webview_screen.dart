import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentMethod; // 'stripe' or 'mobile'
  final String amount;        // e.g., '100 BDT' or '600 BDT'
  final String title;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentMethod,
    required this.amount,
    this.title = 'Payment Portal',
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    final html = _generatePaymentHtml(widget.paymentMethod, widget.amount, isDark);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            debugPrint('Web view error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Navigating to: ${request.url}');

            final lowerUrl = request.url.toLowerCase();

            // Intercept custom scheme redirects or payment success indicators
            if (lowerUrl.contains('projectpulse.payment.com/success') || 
                lowerUrl.contains('success') || 
                lowerUrl.contains('complete')) {
              debugPrint('Success detected in URL: ${request.url}');
              Navigator.of(context).pop('success');
              return NavigationDecision.prevent;
            }

            if (lowerUrl.contains('projectpulse.payment.com/cancel') || 
                lowerUrl.contains('cancel') || 
                lowerUrl.contains('fail')) {
              debugPrint('Cancel/Failure detected in URL: ${request.url}');
              Navigator.of(context).pop('cancel');
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: headerBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor, size: 24),
          onPressed: () => Navigator.of(context).pop('cancel'),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFD946EF)),
            ),
        ],
      ),
    );
  }

  String _generatePaymentHtml(String method, String amount, bool isDark) {
    final bodyBg = isDark ? '#020617' : '#F8FAFC';
    final cardBg = isDark ? '#1E293B' : '#FFFFFF';
    final textColor = isDark ? '#FFFFFF' : '#1E293B';
    final subTextColor = isDark ? '#94A3B8' : '#64748B';
    const primaryColor = '#D946EF';
    final inputBg = isDark ? '#0F172A' : '#F1F5F9';
    final inputBorder = isDark ? '#334155' : '#E2E8F0';

    String paymentFormHtml = '';
    if (method == 'stripe') {
      paymentFormHtml = '''
        <div class="stripe-form">
          <h3 style="margin-top:0; margin-bottom: 15px; font-size: 16px;">Stripe Card Details</h3>
          <div class="form-group">
            <label>Card Number</label>
            <input type="text" placeholder="4242 4242 4242 4242" value="4242 4242 4242 4242" required />
          </div>
          <div style="display: flex; gap: 15px; margin-bottom: 15px;">
            <div class="form-group" style="flex: 1;">
              <label>Expiration Date</label>
              <input type="text" placeholder="MM/YY" value="12/28" required />
            </div>
            <div class="form-group" style="flex: 1;">
              <label>CVC</label>
              <input type="text" placeholder="123" value="456" required />
            </div>
          </div>
          <div class="form-group" style="margin-bottom: 20px;">
            <label>Cardholder Name</label>
            <input type="text" placeholder="John Doe" value="Hossain Ahammed" required />
          </div>
        </div>
      ''';
    } else {
      paymentFormHtml = '''
        <div class="mobile-form">
          <h3 style="margin-top:0; margin-bottom: 15px; font-size: 16px;">Mobile Banking</h3>
          <div class="provider-select" style="display: flex; gap: 12px; margin-bottom: 18px;">
            <div class="provider-card active" onclick="selectProvider(this, 'bkash')">
              <span class="dot"></span> bKash
            </div>
            <div class="provider-card" onclick="selectProvider(this, 'nagad')">
              <span class="dot"></span> Nagad
            </div>
          </div>
          <div class="form-group">
            <label id="phone-label">bKash Account Number</label>
            <input type="tel" placeholder="017XXXXXXXX" value="01712345678" required />
          </div>
          <div class="form-group" style="margin-bottom: 20px;">
            <label>Enter PIN</label>
            <input type="password" placeholder="••••" value="1234" required />
          </div>
        </div>
      ''';
    }

    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Mock Payment Gateway</title>
          <style>
            body {
              background-color: $bodyBg;
              color: $textColor;
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
              margin: 0;
              padding: 16px;
              display: flex;
              flex-direction: column;
              align-items: center;
              justify-content: flex-start;
              box-sizing: border-box;
            }
            .container {
              background-color: $cardBg;
              border-radius: 20px;
              padding: 24px;
              box-shadow: 0 10px 25px rgba(0,0,0,0.15);
              width: 100%;
              max-width: 380px;
              box-sizing: border-box;
              border: 1px solid $inputBorder;
              margin-top: 10px;
            }
            h2 {
              margin-top: 0;
              margin-bottom: 12px;
              text-align: center;
              font-size: 20px;
              font-weight: 700;
            }
            .amount-badge {
              background-color: ${primaryColor}15;
              color: $primaryColor;
              border-radius: 12px;
              padding: 10px;
              text-align: center;
              font-weight: bold;
              font-size: 22px;
              margin-bottom: 20px;
              border: 1px solid ${primaryColor}30;
            }
            .form-group {
              margin-bottom: 12px;
              display: flex;
              flex-direction: column;
            }
            label {
              font-size: 12px;
              color: $subTextColor;
              margin-bottom: 6px;
              font-weight: 600;
              text-transform: uppercase;
              letter-spacing: 0.5px;
            }
            input {
              background-color: $inputBg;
              color: $textColor;
              border: 1px solid $inputBorder;
              border-radius: 10px;
              padding: 12px;
              font-size: 15px;
              outline: none;
              transition: border-color 0.2s;
              box-sizing: border-box;
            }
            input:focus {
              border-color: $primaryColor;
            }
            .btn {
              background-color: $primaryColor;
              color: white;
              border: none;
              border-radius: 12px;
              padding: 14px;
              font-size: 16px;
              font-weight: bold;
              cursor: pointer;
              width: 100%;
              margin-top: 10px;
              box-shadow: 0 4px 10px ${primaryColor}40;
              transition: opacity 0.2s;
            }
            .btn:active {
              opacity: 0.8;
            }
            .btn-cancel {
              background-color: transparent;
              color: $subTextColor;
              border: 1px solid $inputBorder;
              border-radius: 12px;
              padding: 12px;
              font-size: 15px;
              font-weight: 600;
              cursor: pointer;
              width: 100%;
              margin-top: 10px;
              box-shadow: none;
            }
            .provider-select {
              display: flex;
              gap: 12px;
            }
            .provider-card {
              flex: 1;
              border: 1px solid $inputBorder;
              border-radius: 12px;
              padding: 12px;
              text-align: center;
              font-weight: bold;
              cursor: pointer;
              display: flex;
              align-items: center;
              justify-content: center;
              gap: 8px;
              background-color: $inputBg;
              font-size: 14px;
            }
            .provider-card.active {
              border-color: $primaryColor;
              background-color: ${primaryColor}10;
              color: $primaryColor;
            }
            .dot {
              width: 8px;
              height: 8px;
              background-color: $subTextColor;
              border-radius: 50%;
            }
            .provider-card.active .dot {
              background-color: $primaryColor;
            }
            .secure-indicator {
              display: flex;
              align-items: center;
              justify-content: center;
              gap: 6px;
              margin-top: 20px;
              color: $subTextColor;
              font-size: 12px;
            }
          </style>
          <script>
            function selectProvider(element, name) {
              document.querySelectorAll('.provider-card').forEach(card => card.classList.remove('active'));
              element.classList.add('active');
              document.getElementById('phone-label').innerText = (name === 'bkash' ? 'bKash' : 'Nagad') + ' Account Number';
            }
            function handleSuccess() {
              window.location.href = "https://projectpulse.payment.com/success";
            }
            function handleCancel() {
              window.location.href = "https://projectpulse.payment.com/cancel";
            }
          </script>
        </head>
        <body>
          <div class="container">
            <h2>Secure Payment</h2>
            <div class="amount-badge">$amount</div>
            
            $paymentFormHtml
            
            <button class="btn" onclick="handleSuccess()">Confirm & Pay</button>
            <button class="btn-cancel" onclick="handleCancel()">Cancel</button>
            
            <div class="secure-indicator">
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle;">
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
              </svg>
              Secured 256-bit SSL connection
            </div>
          </div>
        </body>
      </html>
    ''';
  }
}
