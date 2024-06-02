import 'package:flutter/material.dart';

class MessageContainer extends StatelessWidget {
  final String text;
  final bool isUserMessage;
  final bool isWeatherMessage;

  const MessageContainer({
    Key? key,
    required this.text,
    this.isUserMessage = false,
    this.isWeatherMessage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> lines = text.split(',');

    return Container(
      constraints: BoxConstraints(maxWidth: 250),
      child: LayoutBuilder(
        builder: (context, constrains) {
          return Container(
            decoration: BoxDecoration(
              color: isUserMessage ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines.map((line) => Text(line)).toList(),
            ),
          );
        },
      ),
    );
  }
}
