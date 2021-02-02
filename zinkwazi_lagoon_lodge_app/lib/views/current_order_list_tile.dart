import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../data_models/item.dart';
import '../view_models/order_vm.dart';

class OrderItemListTile extends StatefulWidget {
  final Item item;
  final int numberOfItem;

  OrderItemListTile(this.item, this.numberOfItem);

  @override
  _OrderItemListTileState createState() => _OrderItemListTileState();
}

class _OrderItemListTileState extends State<OrderItemListTile> {

  double getTextSize(String text) {
    if (text.length > 18) { return 18.0; }
    else { return 22.0; }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderViewModel>(
      builder: (context, orderVM, child) =>
          Card(
            color: CARD_COLOR,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              width: 350,
                padding: widget.item.selectedOptionList.length > 0
                ?  EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0)
                :  EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 220,
                                child: widget.numberOfItem == 1
                                    ? Text('${widget.item.name}', style: TextStyle(fontSize: getTextSize(widget.item.name), fontWeight: FontWeight.bold,),)
                                    : Text('${widget.numberOfItem}x ${widget.item.name}',
                                  style: TextStyle(fontSize: getTextSize(widget.item.name), fontWeight: FontWeight.bold),),
                              ),
                              SizedBox(height: 8.0,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('R ${widget.item.price / 100}', style: TextStyle(fontSize: 16, color: TEXT_COLOR),),
                                  SizedBox(width: 24.0,),
                                  Container(child: Text(widget.item.type, style: TextStyle(fontSize: 16, color: TEXT_COLOR),)),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              ClipOval(
                                child: Material(
                                  color: BUTTON_COLOR, // button color
                                  child: InkWell(
                                    splashColor: REMOVE_COLOR, // inkwell color
                                    child: SizedBox(
                                        width: 40, height: 40, child: Icon(Icons.remove, color: REMOVE_COLOR,)),
                                    onTap: () => orderVM.removeItemFromOrder(widget.item),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.0,),
                              ClipOval(
                                child: Material(
                                  color: BUTTON_COLOR, // button color
                                  child: InkWell(
                                    splashColor: ADD_COLOR, // inkwell color
                                    child: SizedBox(
                                        width: 40, height: 40, child: Icon(Icons.add, color: ADD_COLOR,)),
                                    onTap: () => orderVM.addItemToOrder(widget.item),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      widget.item.selectedOptionList.length > 0
                        ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                          child: Container(color: BACKGROUND_COLOR, height: 0.8, width: 300,),
                        )
                        : SizedBox(),
                      widget.item.selectedOptionList.length > 0
                          ? Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: SizedBox(
                                height: 20.0,
                                child: Text('Options:',),
                              ),
                          )
                          : SizedBox(),
                      widget.item.selectedOptionList.length > 0
                        ? Container(
//                            color: Colors.red,
                            width: 310,
                            child: selectedOptionGridView()
                          )
                        : SizedBox(),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }


  GridView selectedOptionGridView() {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 2.6,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(widget.item.selectedOptionList.length, (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(widget.item.selectedOptionList[index].type,
                style: TextStyle(fontSize: 12)),
            SizedBox(width: 8,),
            Text(widget.item.selectedOptionList[index].name,
              style: TextStyle(fontSize: 12, color: TEXT_COLOR),),
          ],
        );
      }),
    );
  }

}