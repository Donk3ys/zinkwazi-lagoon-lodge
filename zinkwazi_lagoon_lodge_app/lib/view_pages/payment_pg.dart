import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../data_models/menuOrder.dart';
import '../views/loading_view.dart';
import '../core/constants.dart';
import '../view_models/order_vm.dart';


const STATUS_LOADING = "PAYMENT_LOADING";
const STATUS_PENDING = "PAYMENT_PENDING";
const STATUS_SUCCESSFUL = "PAYMENT_SUCCESSFUL";
const STATUS_FAILED = "PAYMENT_FAILED";



class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  OrderViewModel orderViewModel;
  WebViewController _webViewController;
  bool _loadingPayment = true;

  final dateTime = DateTime.now().toLocal();
  String _paymentId = "";

  String _loadHTML() {
    _paymentId = "Y${dateTime.year}M${dateTime.month}D${dateTime.day}H${dateTime.hour}M${dateTime.second}S${dateTime.second}MIL${dateTime.millisecond}MIC${dateTime.microsecond}";
    return '''
      <html>
        <body onload="document.f.submit();">
            <form id="f" name="f" method="POST" action="$SERVER_URL/api/v1/menu/order/payment">
            <input type="hidden" name="amount" value="${orderViewModel.currentOrder.price / 100}" />
            <input type="hidden" name="payment_id" value="$_paymentId" />
            <input type="hidden" name="public_ip" value="$SERVER_URL" />
          </form>
        </body>
      </html>
    ''';
  }



  @override
  void initState() {
    super.initState();
    // Init orderViewModel
    orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Image(
          image: AssetImage('assets/zinkwazi_logo.png'),
          height: 52,
          fit: BoxFit.fitWidth,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: WebView(
              debuggingEnabled: false,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController controller) {
                _webViewController = controller;
                _webViewController.loadUrl(Uri.dataFromString(_loadHTML(), mimeType: 'text/html').toString());
              },
              onPageFinished: (pageUrl) {
                if (pageUrl.contains("/process")) {
                  if (_loadingPayment) {
                    setState(() { _loadingPayment = false; });
                  }
                } else if (pageUrl.contains("return")) {
                  // Place order with upgraded id
                  orderViewModel.placeOrder(_paymentId);

                  // TODO add reset current order function
                  // Make current order null
                  orderViewModel.currentOrder = MenuOrder(id: null, dayId: null, itemList: [], createdAt: null,
                      prepared: false, preparedAt: null, deliveredAt: null, delivered: false);
                  orderViewModel.setView(OrderPageView.OrderHistory);
                  Navigator.pop(context);
                } else if (pageUrl.contains("cancel")) {
                  // TODO remove paymentId from server
                  Navigator.pop(context);
                }
              },
            ),
          ),
          _loadingPayment ? LoadWidget() : SizedBox()
        ]
      ),
    );
  }

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }
}