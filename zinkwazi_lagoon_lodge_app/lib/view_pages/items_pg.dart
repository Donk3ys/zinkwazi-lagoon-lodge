import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../view_models/item_vm.dart';
import '../view_models/order_vm.dart';
import '../views/current_order_tile.dart';
import '../views/item_list_tile.dart';
import '../views/item_type_list_tile.dart';
import '../views/loading_view.dart';

class ItemPage extends StatefulWidget {
  ItemPage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> with WidgetsBindingObserver {
  OrderViewModel orderViewModel;
  ItemViewModel itemViewModel;

  @override
  void initState() {
    super.initState();
    orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
    itemViewModel = Provider.of<ItemViewModel>(context, listen: false);

    // Add observer for lifecycle changes
    WidgetsBinding.instance.addObserver(this);

//    // Run once build complete
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      itemViewModel.getMenuItems();
    });
  }

  @override // class - with WidgetsBindingObserver + init & dispose observers
  Future<void> didChangeAppLifecycleState(final AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      //itemViewModel.getMenuItems();
      itemViewModel.setView(ItemPageView.Types);

      // Check if any updates to orders THIS RUNS EVEN ON ORDER PAGE
//      orderViewModel.checkWorkingOrdersStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    orderViewModel.context = context;

    return Consumer<ItemViewModel>(
      builder: (context, itemVM, child) => Scaffold(
        backgroundColor: BACKGROUND_COLOR,

        body: Builder(builder: (context) {
          itemVM.scaffoldContext = context; // Set scaffold context for snackBar

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: itemVM.state == ItemViewState.Busy
                        ? LoadWidget()
                        : itemVM.view == ItemPageView.Types
                            ? menuTypesCustomScrollView()
                            //? menuTypesListView()
                            : itemsCustomScrollView()
                            //: itemsListView()

                ),
                Consumer<OrderViewModel>(
                  builder: (context, orderVM, child) => Center(
                    child: GestureDetector(
                      child: CurrentOrderTile(
                          orderVM.currentOrder.itemList.isNotEmpty
                              ? 'Current Order'
                              : 'My Orders',
                          orderVM.currentOrder.itemList.length,
                          orderVM.currentOrder.price),
                      onTap: () => orderVM.navigateToOrderPage(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 12.0,
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  // TODO Maybe implement grid view for types
  //  GridView menuTypesListView() {
//    return GridView.count(
//      crossAxisCount: 2,
//      childAspectRatio: 1,
//      children: List.generate(itemViewModel.itemTypeList.length, (index) {
//        return Center(
//          child: Padding(
//            padding: const EdgeInsets.all(6.0),
//            child: GestureDetector(
//              child: ItemTypeListTile(
//                  itemViewModel.itemTypeList[index].name,
//                  itemViewModel.itemTypeList[index].itemCount),
//              onTap: () => itemViewModel.showItemsPage(itemViewModel.itemTypeList[index].name),
//            ),
//          ),
//        );
//      }),
//    );
//  }

  CustomScrollView itemsCustomScrollView() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          floating: true,
          leading: Visibility(
            visible: itemViewModel.view == ItemPageView.Items,
            child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => itemViewModel.setView(ItemPageView.Types)),
          ),
          title: Image(
            image: AssetImage('assets/zinkwazi_logo.png'),
            height: 52,
            fit: BoxFit.fitWidth,
          ),
          centerTitle: true,
          backgroundColor: CARD_COLOR,
          toolbarHeight: 60.0,
          elevation: 0.0,
        ),
        SliverAppBar(
          floating: true,
          shape: RoundedRectangleBorder(
              //borderRadius: BorderRadius.circular(15.0),
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0)
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 30.0),
            child: Column(
              children: [
                Text(
                  itemViewModel.itemList[0].type,
                  style: TextStyle(
                      fontSize: 46, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          backgroundColor: CARD_COLOR,
          toolbarHeight: 70,
          // expandedHeight: 90,
          elevation: 12.0,
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: 20.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index >= itemViewModel.itemList.length) return null;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: ITEM_HORIZONTAL_PADDING),
                  child: Center(child: ItemListTile(itemViewModel.itemList[index])),
                );
              },
            ),
          ),
        ),
      ],
    );
  }


  CustomScrollView menuTypesCustomScrollView() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          leading: Visibility(
            visible: itemViewModel.view == ItemPageView.Items,
            child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => itemViewModel.setView(ItemPageView.Types)),
          ),
          title: Image(
            image: AssetImage('assets/zinkwazi_logo.png'),
            height: 52,
            fit: BoxFit.fitWidth,
          ),
          centerTitle: true,
          // backgroundColor: CARD_COLOR,
          backgroundColor: BACKGROUND_COLOR,
          toolbarHeight: 60.0,
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            //borderRadius: BorderRadius.circular(15.0),
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0)
            ),
          ),
        ),

        // SliverAppBar(
        //   shape: RoundedRectangleBorder(
        //     //borderRadius: BorderRadius.circular(15.0),
        //     borderRadius: BorderRadius.only(
        //         bottomRight: Radius.circular(20.0),
        //         bottomLeft: Radius.circular(20.0)
        //     ),
        //   ),
        //   title: Padding(
        //     padding: const EdgeInsets.only(left: 20.0, bottom: 30.0),
        //     child: Column(
        //       children: [
        //         Text(
        //           "Select Type",
        //           style: TextStyle(
        //               fontSize: 32, fontWeight: FontWeight.bold),
        //         ),
        //       ],
        //     ),
        //   ),
        //   backgroundColor: CARD_COLOR,
        //   toolbarHeight: 60,
        //   // expandedHeight: 90,
        //   elevation: 12.0,
        // ),
        SliverPadding(
          padding: const EdgeInsets.only(top: 20.0),
          sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      if (index >= itemViewModel.itemTypeList.length) return null;
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: GestureDetector(
                            child: ItemTypeListTile(itemViewModel.itemTypeList[index].name,
                                itemViewModel.itemTypeList[index].itemCount),
                            onTap: () => itemViewModel
                                .showItemsPage(itemViewModel.itemTypeList[index].name),
                          ),
                        ),
                      );
                },
              ),
          ),
        ),
      ],
    );
  }

//   ListView menuTypesListView() {
//     return ListView.builder(
//         itemCount: itemViewModel.itemTypeList.length,
//         itemBuilder: (context, index) {
//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.all(6.0),
//               child: GestureDetector(
//                 child: ItemTypeListTile(itemViewModel.itemTypeList[index].name,
//                     itemViewModel.itemTypeList[index].itemCount),
//                 onTap: () => itemViewModel
//                     .showItemsPage(itemViewModel.itemTypeList[index].name),
//               ),
//             ),
//           );
//         });
//   }
//
//   ListView itemsListView() {
//     return ListView.builder(
// //        scrollDirection: Axis.horizontal,
//         itemCount: itemViewModel.itemList.length,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(
//                 vertical: 8.0, horizontal: ITEM_HORIZONTAL_PADDING),
//             child: Center(child: ItemListTile(itemViewModel.itemList[index])),
//           );
//         });
//   }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('Disposing ItemPage');
    super.dispose();
  }
}
