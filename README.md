!!! Temporary solution for adding null safety and updated packages. Please switch back to https://pub.dev/packages/easy_web_view once Rody updates his plugin !!!

# easy_web_view2

Easy Web Views in Flutter on Web and Mobile!

This is an updated version from Rody Davis: https://github.com/rodydavis/easy_web_view

- Supports HTML Content or a Single Element
- Supports Markdown Source
- Supports convert to Flutter widgets
- Supports remote download of url
- Markdown -> Html
- Html -> Markdown
- Supports change in url
- Selectable Text
- Supports multiple views on the same screen if you provide a unique key

Online Demo: https://rodydavis.github.io/easy_web_view

## Getting Started

Setup iOS Info.plist

```
<key>io.flutter.embedded_views_preview</key>
<true/>
```

For Loading a new url or changing width/height just call setState!

```dart
 EasyWebView(
  src: src,
  isHtml: false, // Use Html syntax
  isMarkdown: false, // Use markdown syntax
  convertToWidgets: false, // Try to convert to flutter widgets
  // width: 100,
  // height: 100,
)
```
