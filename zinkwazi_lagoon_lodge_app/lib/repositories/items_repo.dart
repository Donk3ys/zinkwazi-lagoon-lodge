import 'package:dartz/dartz.dart';
import '../core/exception.dart';
import '../core/failure.dart';
import '../data_models/item.dart';
import '../services/network_info.dart';
import '../services/remote_item_src.dart';

abstract class ItemsRepositoryContract {
  Future<Either<Failure, DateTime>> getTimestampDbUpdated();
  Future<Either<Failure, List<Item>>> getAllItems();
}

class ItemRepository implements ItemsRepositoryContract {
  final NetworkInfoContract networkInfo;
  final RemoteItemSourceContract remoteItemSource;

  ItemRepository(this.networkInfo, this.remoteItemSource);

  @override
  Future<Either<Failure, DateTime>> getTimestampDbUpdated() async {
    try {
      // Check for internet connection
      //if (!await networkInfo.isConnected) { return left(OfflineFailure()); }

      final timestamp = await remoteItemSource.getTimestampDbUpdated();
      //print('Timestamp REPO $timestamp');
      return right(timestamp);

    } on RemoteDataSourceException catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Item>>> getAllItems() async {
    try {
      // Check for internet connection
      //if (!await networkInfo.isConnected) { return left(OfflineFailure()); }

      final itemList = await remoteItemSource.getAllItems();
      return right(itemList);

    } on RemoteDataSourceException catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

}