import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';

class ModerationState extends Equatable {
  final List<AssetPathEntity> albums;
  final AssetPathEntity? selectedAlbum;
  final List<AssetEntity> assets;
  final List<AssetEntity> selectedAsset;
  final bool isLoading;
  final bool isUploading;
  final PermissionState permissionState;
  final String statusMessage;
  final bool isChecking;

  const ModerationState({
    this.albums = const [],
    this.selectedAlbum,
    this.assets = const [],
    this.selectedAsset = const [],
    this.isLoading = true,
    this.isUploading = false,
    this.permissionState = PermissionState.notDetermined,
    this.statusMessage = '',
    this.isChecking = false,
  });

  ModerationState copyWith({
    List<AssetPathEntity>? albums,
    AssetPathEntity? selectedAlbum,
    List<AssetEntity>? assets,
    List<AssetEntity>? selectedAsset,
    bool? isLoading,
    bool? isUploading,
    PermissionState? permissionState,
    String? statusMessage,
    bool? isChecking,
  }) {
    return ModerationState(
      albums: albums ?? this.albums,
      selectedAlbum: selectedAlbum ?? this.selectedAlbum,
      assets: assets ?? this.assets,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      permissionState: permissionState ?? this.permissionState,
      statusMessage: statusMessage ?? this.statusMessage,
      isChecking: isChecking ?? this.isChecking,
    );
  }

  @override
  List<Object?> get props => [
    albums,
    selectedAlbum,
    assets,
    selectedAsset,
    isLoading,
    isUploading,
    permissionState,
    statusMessage,
    isChecking,
  ];
}
