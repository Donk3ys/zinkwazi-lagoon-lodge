import 'package:flutter/material.dart';
import '../core/constants.dart';

class ItemTypeListTile extends StatefulWidget {
  final String itemType;
  final int numberOfItem;

  ItemTypeListTile(this.itemType, this.numberOfItem);

  @override
  _ItemTypeListTileState createState() => _ItemTypeListTileState();
}

class _ItemTypeListTileState extends State<ItemTypeListTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: CARD_COLOR,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        width: 350,
        padding: EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(width: 8.0,),
            Icon(Icons.fastfood),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '${widget.itemType}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12.0,),
                  Text('Items ${widget.numberOfItem}', style: TextStyle(color: TEXT_COLOR)),
                ],
              ),
            ),
            Card(
              elevation: 2.0,
              color: CARD_COLOR,
              shape: CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_forward_ios, color: ACCENT_COLOR),
              ),
            )
          ],
        ),
      ),
    );
  }
}
