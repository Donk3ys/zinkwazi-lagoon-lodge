import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../views/loading_view.dart';
import '../view_models/item_vm.dart';


const NAME_NOT_ENTERED_MESSAGE = 'Name required';
const PRICE_NOT_ENTERED_MESSAGE = 'Price required';
const PRICE_NOT_INT_MESSAGE = 'Not a number';


class NewItemTypeListTile extends StatefulWidget {
  @override
  _NewItemTypeListTile createState() => _NewItemTypeListTile();
}

class _NewItemTypeListTile extends State<NewItemTypeListTile> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  bool updating = false;
  bool updatedSuccessfully = true;

  double getTextSize(String text) {
    if (text.length < 18) { return 24.0; }
    else { return 20.0; }
  }

  Future<void> addType(ItemViewModel itemVM)  async {
    if (formKey.currentState.validate()) {
      setState(() {
        updating = true;
      });

      await itemVM.addType(nameController.text.trim());

      updating = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ItemViewModel>(
      builder: (context, itemVM, child) => Container(
        width: 600.0,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 36.0),
          elevation: 12.0,
          color: CARD_COLOR,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Form(
              key: formKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      validator: (name) {
                        return name.isEmpty ? NAME_NOT_ENTERED_MESSAGE : null;
                      },
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
//                          border: InputBorder.none,
                          hintText: 'Type Name'
                      ),
                      controller: nameController,
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
                    onPressed: () => addType(itemVM),
                  ),
                  SizedBox(width: 8),
                  Text('Cancel', style: TextStyle(color: REMOVE_COLOR),),
                  SizedBox(width: 8),
                  RawMaterialButton(
                    elevation: 2.0,
                    fillColor: BUTTON_COLOR,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(8.0),
                    constraints: BoxConstraints(),
                    child: Icon(
                      Icons.close,
                      color: REMOVE_COLOR,
                    ),
                    onPressed: () => itemVM.setView(ItemPageView.Types),
                  ),
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
    super.dispose();
  }

}

