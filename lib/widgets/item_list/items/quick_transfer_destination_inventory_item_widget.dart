import 'package:flutter/material.dart';

class QuickTransferDestinationItemWidget extends StatelessWidget {
  QuickTransferDestinationItemWidget();

  @override
  Widget build(BuildContext context) {
      return Container(
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.1),
          border: Border.all(
            color: Colors.blueGrey.shade900,
            width: 2,
            )
        ),
        child:Center(child: Icon(Icons.add_circle_outline, color:Colors.blueGrey.shade100),)
      );
    }
}
