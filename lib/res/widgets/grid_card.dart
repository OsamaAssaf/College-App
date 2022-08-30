import 'package:flutter/material.dart';

class GridCard extends StatelessWidget {
  const GridCard({Key? key, required this.title, required this.image, required this.onTap})
      : super(key: key);
  final String title;
  final String image;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        // color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        elevation: 5.0,
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(child: Image.asset(image)),
            ),
            Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Color.fromRGBO(233, 166, 166, 1.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
