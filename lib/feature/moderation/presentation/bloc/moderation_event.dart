import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';

abstract class ModerationEvent extends Equatable {
  const ModerationEvent();

  @override
  List<Object?> get props => [];
}

class FetchMediaEvent extends ModerationEvent {
  const FetchMediaEvent();
}

class ChangeAlbumEvent extends ModerationEvent {
  final AssetPathEntity album;

  const ChangeAlbumEvent(this.album);

  @override
  List<Object?> get props => [album];
}

class SelectAssetEvent extends ModerationEvent {
  final AssetEntity asset;

  const SelectAssetEvent(this.asset);

  @override
  List<Object?> get props => [asset];
}

class ClearSelectedAssetEvent extends ModerationEvent {
  const ClearSelectedAssetEvent();
}

class UploadMediaEvent extends ModerationEvent {
  const UploadMediaEvent();
}

class CheckResultEvent extends ModerationEvent {
  const CheckResultEvent();
}

