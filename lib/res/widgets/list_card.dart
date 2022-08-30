import 'package:college_app/res/colors.dart';
import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  const ListCard({Key? key, required this.title, required this.onTap}) : super(key: key);
  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8.0),
        title: Hero(
          tag: title,
          child: Material(
            color: Colors.transparent,
            child: Text(
              title,
              style: TextStyle(
                color: CustomColors.primaryTextColor,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        onTap: onTap,
      ),
    );
  }
}
