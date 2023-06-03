import 'package:easy_web_view2/easy_web_view2.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'impl.dart';

/// EasyWebView implementation
class EasyWebView extends StatefulWidget implements EasyWebViewImpl {
  const EasyWebView({
    required this.src,
    required this.onLoaded,
    Key? key,
    this.height,
    this.width,
    this.webAllowFullScreen = true,
    this.isHtml = false,
    this.isMarkdown = false,
    this.convertToWidgets = false,
    this.headers = const {},
    this.widgetsTextSelectable = false,
    this.crossWindowEvents = const [],
    this.webNavigationDelegate,
  })  : assert((isHtml && isMarkdown) == false),
        super(key: key);

  @override
  _EasyWebViewState createState() => _EasyWebViewState();

  @override
  final double? height;

  @override
  final String src;

  @override
  final double? width;

  @override
  final bool webAllowFullScreen;

  @override
  final bool isMarkdown;

  @override
  final bool isHtml;

  @override
  final bool convertToWidgets;

  @override
  final Map<String, String> headers;

  @override
  final bool widgetsTextSelectable;

  @override
  final void Function() onLoaded;

  @override
  final List<CrossWindowEvent> crossWindowEvents;

  @override
  final WebNavigationDelegate? webNavigationDelegate;
}

class _EasyWebViewState extends State<EasyWebView> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(_updateUrl(widget.src)),
        headers: widget.headers,
      );

    if (widget.crossWindowEvents.isNotEmpty) {
      for (final windowEvent in widget.crossWindowEvents.toSet()) {
        _webViewController.addJavaScriptChannel(
          windowEvent.name,
          onMessageReceived: (javascriptMessage) =>
              windowEvent.eventAction(javascriptMessage.message),
        );
      }
    }

    _webViewController.setNavigationDelegate(
      NavigationDelegate(onNavigationRequest: (navigationRequest) async {
        if (widget.webNavigationDelegate == null) {
          return NavigationDecision.navigate;
        }

        final webNavigationDecision = await widget.webNavigationDelegate!(
            WebNavigationRequest(navigationRequest.url));
        return (webNavigationDecision == WebNavigationDecision.prevent)
            ? NavigationDecision.prevent
            : NavigationDecision.navigate;
      }),
    );
  }

  @override
  void didUpdateWidget(EasyWebView oldWidget) {
    if (oldWidget.src != widget.src) {
      _webViewController.loadRequest(
        Uri.parse(_updateUrl(widget.src)),
        headers: widget.headers,
      );
    }

    super.didUpdateWidget(oldWidget);
  }

  String _updateUrl(String url) {
    String _src = url;
    if (widget.isMarkdown) {
      _src = "data:text/html;charset=utf-8," +
          Uri.encodeComponent(EasyWebViewImpl.md2Html(url));
    }
    if (widget.isHtml) {
      _src = "data:text/html;charset=utf-8," +
          Uri.encodeComponent(EasyWebViewImpl.wrapHtml(url));
    }
    widget.onLoaded();
    return _src;
  }

  @override
  Widget build(BuildContext context) {
    return OptionalSizedChild(
      width: widget.width,
      height: widget.height,
      builder: (w, h) {
        String src = widget.src;
        if (widget.convertToWidgets) {
          if (EasyWebViewImpl.isUrl(src)) {
            return RemoteMarkdown(
              src: src,
              headers: widget.headers,
              isSelectable: widget.widgetsTextSelectable,
            );
          }
          String _markdown = '';
          if (widget.isMarkdown) {
            _markdown = src;
          }
          if (widget.isHtml) {
            src = EasyWebViewImpl.wrapHtml(src);
            _markdown = EasyWebViewImpl.html2Md(src);
          }
          return LocalMarkdown(
            data: _markdown,
            isSelectable: widget.widgetsTextSelectable,
          );
        }

        return WebViewWidget(
          key: widget.key,
          controller: _webViewController,
        );
      },
    );
  }
}
