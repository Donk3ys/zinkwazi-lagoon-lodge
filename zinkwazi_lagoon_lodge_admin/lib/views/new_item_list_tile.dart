import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../views/loading_view.dart';
import '../view_models/item_vm.dart';


const NAME_NOT_ENTERED_MESSAGE = 'Name required';
const PRICE_NOT_ENTERED_MESSAGE = 'Price required';
const PRICE_NOT_INT_MESSAGE = 'Not a number';


class NewItemListTile extends StatefulWidget {
  @override
  _NewItemListTile createState() => _NewItemListTile();
}

class _NewItemListTile extends State<NewItemListTile> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final subheadingController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();


  bool updating = false;
  bool updatedSuccessfully = true;

  double getTextSize(String text) {
    if (text.length < 18) { return 24.0; }
    else { return 20.0; }
  }

  Future<void> addItem(ItemViewModel itemVM)  async {
    if (formKey.currentState.validate()) {
      setState(() {
        updating = true;
      });

      final addedItem = await itemVM.addItem(
        name: nameController.text.trim(),
        subheading: subheadingController.text.trim(),
        price: priceController.text.trim(),
        description: descriptionController.text.trim(),
      );

      addedItem ? updatedSuccessfully = true : updatedSuccessfully = false;

      updating = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ItemViewModel>(
      builder: (context, itemVM, child) => Container(
        width: 800.0,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 36.0),
          elevation: 12.0,
          color: CARD_COLOR,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          validator: (name) {
                            return name.isEmpty ? NAME_NOT_ENTERED_MESSAGE : null;
                          },
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(hintText: 'Name'),
                          controller: nameController,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                                hintText: 'Subheading'
                            ),
                            controller: subheadingController
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                            validator: (price) {
                              try {
                                double.parse(priceController.text.trim());
                              } catch(error) {
                                return PRICE_NOT_INT_MESSAGE;
                              }
                              return price.isEmpty ? PRICE_NOT_ENTERED_MESSAGE : null;
                            },
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(hintText: 'Price',),
                            controller: priceController
                        ),
                      ),
                      //Text(widget.item.name, style: TextStyle(fontSize: getTextSize(widget.item.name), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Description'
                            ),
                            maxLines: 2,
                            controller: descriptionController
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(updatedSuccessfully ? 'Add' : 'Failed', style: TextStyle(color: updatedSuccessfully ? ADD_COLOR : REMOVE_COLOR),),
                      SizedBox(width: 8),
                      updating
                          ? LoadWidget()
                          : RawMaterialButton(
                        elevation: 2.0,
                        fillColor: BUTTON_COLOR,
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(8.0),
                        constraints: BoxConstraints(),
                        child: Icon(
                          Icons.add,
                          color: ADD_COLOR,
                        ),
                        onPressed: () => addItem(itemVM),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                          child: Text('Cancel', style: TextStyle(color: REMOVE_COLOR),),
                        onTap: () => itemVM.setView(ItemPageView.Items),
                      ),
                      SizedBox(width: 8),
                      updating
                          ? LoadWidget()
                          : RawMaterialButton(
                        elevation: 2.0,
                        fillColor: BUTTON_COLOR,
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(8.0),
                        constraints: BoxConstraints(),
                        child: Icon(
                          Icons.close,
                          color: REMOVE_COLOR,
                        ),
                        onPressed: () => itemVM.setView(ItemPageView.Items),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    subheadingController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

}

