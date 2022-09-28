import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

import 'package:delta_markdown/delta_markdown.dart';
import 'package:markdown/markdown.dart';

class FlutterQuillWidget extends StatefulWidget {
  const FlutterQuillWidget({Key? key}) : super(key: key);

  @override
  State<FlutterQuillWidget> createState() => _FlutterQuillWidgetState();
}

class _FlutterQuillWidgetState extends State<FlutterQuillWidget> {
  QuillController controller = QuillController.basic();
  String textPreview = '';

  @override
  void initState() {
    controller.addListener(() {
      textPreview = quillDeltaToHtml(controller.document.toDelta())
          .replaceAll('**', '<i>');
      setState(() {});
      print(textPreview);
    });
    super.initState();
  }

  String quillDeltaToHtml(Delta delta) {
    final convertedValue = jsonEncode(delta.toJson());
    final markdown = deltaToMarkdown(convertedValue);
    return markdownToHtml(markdown, inlineSyntaxes: [InlineHtmlSyntax()]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 4,
            child: Column(
              children: [
                QuillToolbar.basic(
                  controller: controller,
                  showFontSize: false,
                  showFontFamily: false,
                  showColorButton: false,
                  showDividers: false,
                  showQuote: false,
                  showBackgroundColorButton: false,
                  showSearchButton: false,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  child: QuillEditor.basic(
                    controller: controller,
                    readOnly: false,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.amber,
              child: Html(data: textPreview),
            ),
          ),
        ],
      ),
    );
  }
}
