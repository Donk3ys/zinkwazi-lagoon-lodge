import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../views/new_item_list_tile.dart';
import '../views/new_item_type_list_tile.dart';
import '../core/constants.dart';
import '../view_models/item_vm.dart';
import '../views/item_list_tile.dart';
import '../views/item_type_list_tile.dart';

class ItemPage extends StatefulWidget {
  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  ItemViewModel itemViewModel;

  @override
  void initState() {
    super.initState();
    itemViewModel = Provider.of<ItemViewModel>(context, listen: false);
    itemViewModel.context = context;

    // Run once build complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      itemViewModel.getMenuItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemViewModel>(
        builder: (context, itemVM, child) => Scaffold(
              backgroundColor: BACKGROUND_COLOR,
              floatingActionButton: FloatingActionButton(
                backgroundColor: ACCENT_COLOR,
                child: Icon(Icons.add),
                onPressed: () => itemVM.view == ItemPageView.Items
                    ? itemVM.setView(ItemPageView.AddItem)
                    : itemVM.setView(ItemPageView.AddType),
              ),
              body: Builder(builder: (BuildContext context) {
                itemViewModel.context = context;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 12.0,
                    ),
                    Visibility(
                      maintainSize: false,
                      visible: itemVM.view == ItemPageView.Items ||
                          itemVM.view == ItemPageView.AddItem,
                      child: Text(
                        itemVM.selectedTypeName,
                        style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                        child: itemVM.view == ItemPageView.Types ||
                                itemVM.view == ItemPageView.AddType
                            ? menuTypesListView()
                            : itemsListView()),
                    itemVM.view == ItemPageView.AddType
                        ? NewItemTypeListTile()
                        : SizedBox(),
                    itemVM.view == ItemPageView.AddItem
                        ? NewItemListTile()
                        : SizedBox(),
                    SizedBox(
                      height: 2.0,
                    )
                  ],
                );
              }),
            ));
  }

  ListView menuTypesListView() {
    return ListView.builder(
        itemCount: itemViewModel.itemTypeList.length,
        itemBuilder: (context, index) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: GestureDetector(
                  child: ItemTypeListTile(
                      itemViewModel.itemTypeList[index].name,
                      itemViewModel.itemTypeList[index].itemCount),
                  onTap: () {
                    itemViewModel.selectedTypeName =
                        itemViewModel.itemTypeList[index].name;
                    itemViewModel.showItemsPage();
                  }),
            ),
          );
        });
  }

  ListView itemsListView() {
    return ListView.builder(
        itemCount: itemViewModel.itemList.length,
        itemBuilder: (context, index) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ItemListTile(itemViewModel.itemList[index]),
          ));
        });
  }
}
