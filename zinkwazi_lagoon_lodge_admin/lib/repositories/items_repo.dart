import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../core/success.dart';
import '../core/exception.dart';
import '../core/failure.dart';
import '../data_models/item.dart';
import '../services/local_data_src.dart';
import '../services/remote_item_src.dart';

abstract class ItemsRepositoryContract {
  Future<Either<Failure, List<Item>>> getAllItems();
  Future<Either<Failure, Item>> updatedItem(Item updatedItem);
  Future<Either<Failure, Item>> activateItem(String id, bool active);
  Future<Either<Failure, Item>> addItem(Item addedItem);
  Future<Either<Failure, Success>> deleteItem(String id);
}

class ItemRepository implements ItemsRepositoryContract {
  final RemoteItemSourceContract remoteItemSource;
  final LocalDataSourceContract localDataSource;

  ItemRepository({
    @required this.remoteItemSource,
    @required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Item>>> getAllItems() async {
    try {
      final itemList = await remoteItemSource.getAllItems();
      return right(itemList);

    } on RemoteDataSourceException catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }


  @override
  Future<Either<Failure, Item>> updatedItem(Item updatedItem) async {
    try {
      // Get jwt
      final jwt = await localDataSource.jwt;

      final item = await remoteItemSource.updatedItem(jwt, updatedItem);
      return right(item);

    } on RemoteDataSourceException catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Item>> activateItem(String id, bool active) async {
    try {
      // Get jwt
      final jwt = await localDataSource.jwt;

      final item = await remoteItemSource.activateItem(jwt, id, active);
      return right(item);

    } on RemoteDataSourceException catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Item>> addItem(Item addedItem) async {
    try {
      // Get jwt
      final jwt = await localDataSource.jwt;

      final item = await remoteItemSource.addItem(jwt, addedItem);
      return right(item);

    } on RemoteDataSourceException catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> deleteItem(String id) async {
    try {
      // Get jwt
      final jwt = await localDataSource.jwt;

      final success = await remoteItemSource.deleteItem(jwt, id);
      return right(success);

    } on RemoteDataSourceException catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }


}

//  @override
//  Future<Either<Failure, DateTime>> getTimestampDbUpdated() async {
//    try {
//      final timestamp = await remoteItemSource.getTimestampDbUpdated();
//      //print('Timestamp REPO $timestamp');
//      return right(timestamp);
//
//    } on RemoteDataSourceException catch (error) {
//      return left(ServerFailure(error.toString()));
//    }
//  }