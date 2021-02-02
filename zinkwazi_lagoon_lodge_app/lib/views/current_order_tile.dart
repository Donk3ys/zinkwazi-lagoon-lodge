import 'package:flutter/material.dart';
import '../core/constants.dart';

class CurrentOrderTile extends StatelessWidget {
  final String title;
  final int numberOfItems;
  final int price;

  CurrentOrderTile(this.title, this.numberOfItems, this.price);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0.0),
      color: CARD_COLOR,
      elevation: 12.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        height: 70.0,
        width: 350.0,
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(width: 8.0),
            Icon(Icons.fastfood),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                numberOfItems > 0 ? SizedBox(height: 8.0) : SizedBox(height: 0.0,),
                numberOfItems > 0
                  ? Row(
                    children: <Widget>[
                      Text('Items $numberOfItems'),
                      SizedBox(width: 12.0),
                      Text('Total R ${price / 100}')
                    ],
                  )
                  : SizedBox(height: 0.0,)
              ],
            ),
            SizedBox(width: 60.0),
          ],
        ),
      ),
    );
  }
}