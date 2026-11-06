import 'package:flutter/material.dart';

class ReplyCard extends StatelessWidget {
  const ReplyCard({Key? key, required this.message}) : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: Colors.orange[600],
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 60, top: 4, bottom: 20),
                child: Text(
                  message,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 6,
                child: Text(
                  '12.23',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
