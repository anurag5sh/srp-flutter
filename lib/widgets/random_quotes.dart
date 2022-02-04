import 'package:flutter/material.dart';

class RandomQuotes extends StatelessWidget {
  // const RandomQuotes({ Key? key }) : super(key: key);
  final author;
  final quote;

  RandomQuotes({@required this.author, @required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '“ $quote ”',
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '-$author',
                style: TextStyle(fontSize: 15),
              ))
        ],
      ),
    );
  }
}
