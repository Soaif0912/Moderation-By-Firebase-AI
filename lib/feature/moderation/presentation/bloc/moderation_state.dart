import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';

class ModerationState extends Equatable {
  final List<AssetPathEntity> albums;
  final AssetPathEntity? selectedAlbum;
  final List<AssetEntity> assets;
  final List<AssetEntity> selectedAsset;
  final bool isLoading;
  final PermissionState permissionState;
  final String statusMessage;

  const ModerationState({
    this.albums = const [],
    this.selectedAlbum,
    this.assets = const [],
    this.selectedAsset = const [],
    this.isLoading = true,
    this.permissionState = PermissionState.notDetermined,
    this.statusMessage = '',
  });

  ModerationState copyWith({
    List<AssetPathEntity>? albums,
    AssetPathEntity? selectedAlbum,
    List<AssetEntity>? assets,
    List<AssetEntity>? selectedAsset,
    bool? isLoading,
    PermissionState? permissionState,
    String? statusMessage,
  }) {
    return ModerationState(
      albums: albums ?? this.albums,
      selectedAlbum: selectedAlbum ?? this.selectedAlbum,
      assets: assets ?? this.assets,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      isLoading: isLoading ?? this.isLoading,
      permissionState: permissionState ?? this.permissionState,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  @override
  List<Object?> get props => [
    albums,
    selectedAlbum,
    assets,
    selectedAsset,
    isLoading,
    permissionState,
    statusMessage,
  ];
}
