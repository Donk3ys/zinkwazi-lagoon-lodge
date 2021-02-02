
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data_models/itemOption.dart';
import '../core/constants.dart';
import '../data_models/item.dart';
import '../view_models/item_vm.dart';
import 'loading_view.dart';

const TEXT_SIZE = 16.0;
const LABEL_SIZE = 10.0;

const NAME_NOT_ENTERED_MESSAGE = 'Name required';
const PRICE_NOT_ENTERED_MESSAGE = 'Price required';
const PRICE_NOT_INT_MESSAGE = 'Not a number';

class ItemListTile extends StatefulWidget {
  final Item item;
  ItemListTile(this.item);

  @override
  _ItemListTile createState() => _ItemListTile();
}

class _ItemListTile extends State<ItemListTile> {
  ItemViewModel itemViewModel;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final subheadingController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isEditing = false;
  bool updating = false;
  bool deleting = false;
  bool updatedSuccessfully = true;
  List<ItemOption> _itemOptionList = [];

  Future<void> updateItem(ItemViewModel itemVM)  async {
    if (formKey.currentState.validate()) {
      setState(() {
        updating = true;
      });

      print(_itemOptionList.toString());

      final updatedItem = await itemVM.updateItem(
        id: widget.item.id,
        name: nameController.text.trim(),
        subheading: subheadingController.text.trim(),
        active: widget.item.active,
        price: priceController.text.trim(),
        description: descriptionController.text.trim(),
        optionList: _itemOptionList,
      );

      updatedItem != null ? updatedSuccessfully = true : updatedSuccessfully = false;

      updating = false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Get view model provider
    itemViewModel = Provider.of<ItemViewModel>(context, listen: false);

    _itemOptionList = [...widget.item.optionList];
  }


  @override
  Widget build(BuildContext context) {
    // Init values for text controllers
    nameController.text = widget.item.name;
    priceController.text = '${widget.item.price / 100}';
    subheadingController.text = widget.item.subheading != null ? widget.item.subheading : null;
    descriptionController.text = widget.item.description != null ? widget.item.description : null;

    return Consumer<ItemViewModel>(
        builder: (context, itemVM, child) => Container(
          width: 800.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 6.0,
                color: CARD_COLOR,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: isEditing ? editingView(itemVM) : nonEditView()
                ),
              ),
              isEditing
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(updatedSuccessfully ? 'Delete' : 'Failed', style: TextStyle(color: REMOVE_COLOR),),
                  SizedBox(width: 8),
                  deleting
                      ? LoadWidget()
                      : RawMaterialButton(
                    elevation: 2.0,
                    fillColor: BUTTON_COLOR,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(8.0),
                    constraints: BoxConstraints(),
                    child: Icon(
                      Icons.delete_forever,
                      color: REMOVE_COLOR,
                    ),
                    onPressed: () => null,
                    onLongPress: () async {
                      setState(() { deleting = true; });
                      final success = await itemVM.deleteItem(widget.item.id);
                      if (success) {
                        isEditing = false;
                        deleting = false;
                      }
                    },
                  ),
                ],
              )
                  : SizedBox(),
            ],
          ),
        ),
    );
  }

  Widget nonEditView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text('Id',
                  style: TextStyle(fontSize: LABEL_SIZE, color: TEXT_COLOR),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text('Status',
                  style: TextStyle(fontSize: LABEL_SIZE, color: TEXT_COLOR),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text('Name',
                  style: TextStyle(fontSize: LABEL_SIZE, color: TEXT_COLOR),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: Text('Subheading',
                  style: TextStyle(fontSize: LABEL_SIZE, color: TEXT_COLOR),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Text('Price',
                  style: TextStyle(fontSize: LABEL_SIZE, color: TEXT_COLOR),
                  textAlign: TextAlign.center,
                ),
              ),
              //Text(widget.item.name, style: TextStyle(fontSize: getTextSize(widget.item.name), fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 4.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(widget.item.id.toString(),
                  style: TextStyle(fontSize: TEXT_SIZE, color: TEXT_COLOR),
                ),
              ),
              Expanded(
                flex: 2,
                child: GestureDetector(
                        child: Text( widget.item.active ? "Active" : "Hidden",
                          style: TextStyle(fontSize: TEXT_SIZE, color: widget.item.active ? ADD_COLOR : REMOVE_COLOR),
                        ),
                        onTap: () =>  itemViewModel.activateItem(id: widget.item.id, active: !widget.item.active),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(widget.item.name.toString(),
                  style: TextStyle(fontSize: TEXT_SIZE),
                  //style: TextStyle(fontSize: TEXT_SIZE, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: Text(widget.item.subheading != null ? widget.item.subheading : '',
                  style: TextStyle(fontSize: TEXT_SIZE),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Text('R  ${(widget.item.price / 100).toString()}',
                  style: TextStyle(fontSize: TEXT_SIZE),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 2.0,),
              //Text(widget.item.name, style: TextStyle(fontSize: getTextSize(widget.item.name), fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16.0,),
          Text('Description',
            style: TextStyle(fontSize: LABEL_SIZE, color: TEXT_COLOR),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Text(widget.item.description != null ? widget.item.description : '',
                  style: TextStyle(fontSize: 14.0),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Edit', style: TextStyle(color: WARNING_COLOR)),
                    SizedBox(width: 8),
                    RawMaterialButton(
                      fillColor: BUTTON_COLOR,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(8.0),
                      constraints: BoxConstraints(),
                      child: Icon(Icons.edit, color: WARNING_COLOR,),
                      onPressed: () {
                        setState(() {
                          isEditing = true;
                        });
                      },
                    )
                  ],
                ),
              )
            ],
          ),
          Divider(color: BACKGROUND_COLOR, thickness: 1.0,),
          SizedBox(height: 4.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Text('Option Type',
                  style: TextStyle(fontSize: LABEL_SIZE, color: TEXT_COLOR),
                  textAlign: TextAlign.left,
                ),
              ),
              Expanded(
                child: Text('Option Name',
                  style: TextStyle(fontSize: LABEL_SIZE, color: TEXT_COLOR),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          optionListView(),
        ],
      ),
    );
  }

  Widget editingView(ItemViewModel itemVM) {
    return Form(
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
                  decoration: InputDecoration(hintText: 'item name'),
                  controller: nameController,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        hintText: 'subheading'
                    ),
                    controller: subheadingController
                ),
              ),
              SizedBox(width: 16),
              Text('R ', style: TextStyle(fontSize: TEXT_SIZE),),
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
                    decoration: InputDecoration(hintText: 'price',),
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
                        hintText: 'description'
                    ),
                    maxLines: 3,
                    controller: descriptionController
                ),
              ),
              SizedBox(width: 16),
              Text(updatedSuccessfully ? 'Update' : 'Failed', style: TextStyle(color: updatedSuccessfully ? WARNING_COLOR : REMOVE_COLOR),),
              SizedBox(width: 8),
              updating
                  ? LoadWidget()
                  : RawMaterialButton(
                fillColor: BUTTON_COLOR,
                shape: CircleBorder(),
                padding: EdgeInsets.all(8.0),
                constraints: BoxConstraints(),
                child: Icon(Icons.cloud_upload, color: WARNING_COLOR,),
                onPressed: () async {
                  await updateItem(itemVM);
                  if (updatedSuccessfully) { isEditing = false; }
                },
              ),
              SizedBox(width: 8),
              Text('Cancel', style: TextStyle(color: REMOVE_COLOR),),
              SizedBox(width: 8),
              RawMaterialButton(
                fillColor: BUTTON_COLOR,
                shape: CircleBorder(),
                padding: EdgeInsets.all(8.0),
                constraints: BoxConstraints(),
                child: Icon(Icons.close, color: REMOVE_COLOR,),
                onPressed: () {
                    setState(() {
                      isEditing = false;
                      // Shallow copy
                      _itemOptionList = [...widget.item.optionList];
                      // Set all options to not be deleted
                      for (var option in _itemOptionList) { option.delete = false; }
                    });
                },
              )
            ],
          ),
          optionListView(),
          Row(
            children: [
              Text('Add option', style: TextStyle(color: ADD_COLOR),),
              SizedBox(width: 8),
              RawMaterialButton(
                fillColor: BUTTON_COLOR,
                shape: CircleBorder(),
                padding: EdgeInsets.all(8.0),
                constraints: BoxConstraints(),
                child: Icon(Icons.add, color: ADD_COLOR,),
                onPressed: () {
                  setState(() {
                    _itemOptionList.add(
                        ItemOption(
                            id: null,
                            itemId: widget.item.id,
                            type: '',
                            name: '',
                            delete: false
                        ),
                    );
                  });
                },
              )
            ],
          )
        ],
      ),
    );
  }

  ListView optionListView() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _itemOptionList.length,
        itemBuilder: (context, index) {
          // if item option not marked for delete
          return !_itemOptionList[index].delete
          ?  Center(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: isEditing 
                    ? itemOptionEditor(_itemOptionList[index], index)
                    : itemOption(_itemOptionList[index])
              ))
          : SizedBox();
        });
  }


  Widget itemOption(ItemOption itemOption) {
    return Row(
      children: [
        Expanded(
          child: Text(itemOption.type),
        ),
        Expanded(
          child: Text(itemOption.name),
        ),
      ],
    );
  }
  

  Widget itemOptionEditor(ItemOption itemOption, int index) {
    final typeOptionController = TextEditingController();
    final nameOptionController = TextEditingController();

    typeOptionController.text = itemOption.type;
    nameOptionController.text = itemOption.name;

    return Row(
      children: [
        SizedBox(width: 10),
        Text('Remove', style: TextStyle(color: REMOVE_COLOR),),
        SizedBox(width: 8),
        RawMaterialButton(
          fillColor: BUTTON_COLOR,
          shape: CircleBorder(),
          padding: EdgeInsets.all(8.0),
          constraints: BoxConstraints(),
          child: Icon(Icons.remove, color: REMOVE_COLOR,),
          onPressed: () {
            setState(() {
              _itemOptionList[index].delete = true;
            });
          },
        ),
        SizedBox(width: 20),
        SizedBox(
          width: 600,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                    validator: (type) {
                      return type.isEmpty ? 'Cannot be empty' : null;
                    },
                    onChanged: (type) {
                      _itemOptionList[index].type = type.trim();
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(hintText: 'Type',),
                    controller: typeOptionController
                ),
              ),
              SizedBox(width: 20,),
              Expanded(
                child: TextFormField(
                    validator: (name) {
                      return name.isEmpty ? 'Cannot be empty' : null;
                    },
                    onChanged: (name) {
                      _itemOptionList[index].name = name.trim();
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(hintText: 'Name',),
                    controller: nameOptionController
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
  

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    subheadingController.dispose();
    priceController.dispose();
    descriptionController.dispose();
  }

}



