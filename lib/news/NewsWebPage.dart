import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

/**
 * @Description  网页，h5
 * @Author  zhibuyu
 * @Date 2018/10/19  9:09
 * @Version  1.0
 */
class NewsWebPage extends StatefulWidget {
  String news_url;
  String title;

  NewsWebPage(this.news_url, this.title);

  @override
  State<StatefulWidget> createState() => new NewsWebPageState(news_url, title);
}

class NewsWebPageState extends State<NewsWebPage> {
  String news_url;
  String title;

  // 标记是否是加载中
  bool loading = true;

  // 标记当前页面是否是我们自定义的回调页面
  bool isLoadingCallbackPage = false;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();

  // URL变化监听器
  StreamSubscription<String> onUrlChanged;

  // WebView加载状态变化监听器
  StreamSubscription<WebViewStateChanged> onStateChanged;

  // 插件提供的对象，该对象用于WebView的各种操作
  FlutterWebviewPlugin flutterWebViewPlugin = new FlutterWebviewPlugin();

  NewsWebPageState(this.news_url, this.title);

  @override
  void initState() {
    onStateChanged =
        flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      // state.type是一个枚举类型，取值有：WebViewState.shouldStart, WebViewState.startLoad, WebViewState.finishLoad
      if (state.type == WebViewState.shouldStart) {
        // 准备加载
        setState(() {
          loading = true;
        });
      } else if (state.type == WebViewState.startLoad) {
        // 开始加载
      } else if (state.type == WebViewState.finishLoad) {
        // 加载完成
        setState(() {
          loading = false;
        });
        if (isLoadingCallbackPage) {
          // 当前是回调页面，则调用js方法获取数据
          parseResult();
        }
      }
    });
  }

  // 解析WebView中的数据
  void parseResult() {
//    flutterWebViewPlugin.evalJavascript("get();").then((result) {
//      // result json字符串，包含token信息
//
//    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> titleContent = [];
    titleContent.add(
      new Container(
        child: new Text(
          title,
          style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
//          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        alignment: FractionalOffset.centerLeft,
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
//        margin: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 0.0),
      ),
//        new Text(
//      title,
////      "新闻详情",
//      style: new TextStyle(color: Colors.white),
//    )
    );
    if (loading) {
      // 如果还在加载中，就在标题栏上显示一个圆形进度条
      titleContent.add(new CupertinoActivityIndicator());
    }
    titleContent.add(new Container(width: 50.0));
    // WebviewScaffold是插件提供的组件，用于在页面上显示一个WebView并加载URL
    return new WebviewScaffold(
      key: scaffoldKey,
      url: news_url,
      // 登录的URL
      appBar: new AppBar(
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: titleContent,
        ),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      withZoom: true,
      // 允许网页缩放
      withLocalStorage: true,
      // 允许LocalStorage
      withJavascript: true, // 允许执行js代码
    );
  }

  @override
  void dispose() {
    // 回收相关资源
    // Every listener should be canceled, the same should be done with this stream.
    if (onUrlChanged != null) {
      onUrlChanged.cancel();
    }
    if (onStateChanged != null) {
      onStateChanged.cancel();
    }
    if (flutterWebViewPlugin != null) {
      flutterWebViewPlugin.dispose();
    }
    super.dispose();
  }
}
