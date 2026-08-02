import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import 'moderation_event.dart';
import 'moderation_state.dart';

class ModerationBloc extends Bloc<ModerationEvent, ModerationState> {
  ModerationBloc() : super(const ModerationState()) {
    on<FetchMediaEvent>(_onFetchMedia);
    on<ChangeAlbumEvent>(_onChangeAlbum);
    on<SelectAssetEvent>(_onSelectAsset);
    on<ClearSelectedAssetEvent>(_onClearSelectedAsset);
    on<UploadMediaEvent>(_onUploadMedia);
  }

  Future<void> _onFetchMedia(
    FetchMediaEvent event,
    Emitter<ModerationState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        statusMessage: 'Requesting permission...',
      ),
    );

    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend()
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => PermissionState.notDetermined,
          );

      if (ps.isAuth || ps.hasAccess) {
        emit(
          state.copyWith(
            permissionState: ps,
            statusMessage: 'Loading albums...',
          ),
        );

        final List<AssetPathEntity> albums =
            await PhotoManager.getAssetPathList(
              type: RequestType.common,
              hasAll: true,
            ).timeout(const Duration(seconds: 8), onTimeout: () => []);

        if (albums.isNotEmpty) {
          final selectedAlbum = albums.first;
          final List<AssetEntity> assets = await selectedAlbum
              .getAssetListRange(start: 0, end: 100)
              .timeout(const Duration(seconds: 8), onTimeout: () => []);

          emit(
            state.copyWith(
              albums: albums,
              selectedAlbum: selectedAlbum,
              assets: assets,
              permissionState: ps,
              isLoading: false,
              statusMessage:
                  'Found ${assets.length} items in "${selectedAlbum.name}"',
            ),
          );
        } else {
          emit(
            state.copyWith(
              albums: [],
              assets: [],
              permissionState: ps,
              isLoading: false,
              statusMessage: 'No albums found on device or timed out.',
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            permissionState: ps,
            isLoading: false,
            statusMessage:
                'Permission state: ${ps.name}. Permission not granted.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          statusMessage: 'Error loading media: $e',
        ),
      );
    }
  }

  Future<void> _onChangeAlbum(
    ChangeAlbumEvent event,
    Emitter<ModerationState> emit,
  ) async {
    final album = event.album;
    emit(
      state.copyWith(
        selectedAlbum: album,
        isLoading: true,
        statusMessage: 'Loading ${album.name}...',
      ),
    );

    try {
      final List<AssetEntity> assets = await album.getAssetListRange(
        start: 0,
        end: 100,
      );
      emit(
        state.copyWith(
          assets: assets,
          isLoading: false,
          statusMessage: 'Found ${assets.length} items in "${album.name}"',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          statusMessage: 'Error loading album: $e',
        ),
      );
    }
  }

  void _onSelectAsset(SelectAssetEvent event, Emitter<ModerationState> emit) {
    final currentSelected = List<AssetEntity>.from(state.selectedAsset);
    final isAlreadySelected = currentSelected.any(
      (a) => a.id == event.asset.id,
    );
    if (isAlreadySelected) {
      currentSelected.removeWhere((a) => a.id == event.asset.id);
    } else {
      currentSelected.add(event.asset);
    }
    emit(state.copyWith(selectedAsset: currentSelected));
  }

  void _onClearSelectedAsset(
    ClearSelectedAssetEvent event,
    Emitter<ModerationState> emit,
  ) {
    emit(state.copyWith(selectedAsset: const []));
  }

  Future<void> _onUploadMedia(
    UploadMediaEvent event,
    Emitter<ModerationState> emit,
  ) async {
    if (state.selectedAsset.isEmpty) {
      emit(state.copyWith(statusMessage: 'Please select media to upload.'));
      return;
    }

    emit(
      state.copyWith(
        isUploading: true,
        statusMessage: 'Preparing media files...',
      ),
    );

    try {
      final storageRef = FirebaseStorage.instance.ref();
      int successCount = 0;
      final total = state.selectedAsset.length;

      for (int i = 0; i < total; i++) {
        final asset = state.selectedAsset[i];

        // Timeout fetching local file path from PhotoManager asset
        final File? file = await asset.file.timeout(
          const Duration(seconds: 5),
          onTimeout: () => null,
        );

        if (file == null || !await file.exists()) {
          emit(
            state.copyWith(
              statusMessage:
                  'Could not access file ${i + 1}/$total (${asset.title})',
            ),
          );
          continue;
        }

        final String cleanTitle = (asset.title ?? 'media').replaceAll(
          RegExp(r'[^\w\.-]'),
          '_',
        );
        final String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_$cleanTitle';

        Reference destRef;
        if (asset.type == AssetType.image) {
          destRef = storageRef.child('images/$fileName');
        } else if (asset.type == AssetType.video) {
          destRef = storageRef.child('videos/$fileName');
        } else {
          destRef = storageRef.child('others/$fileName');
        }

        emit(
          state.copyWith(
            statusMessage: 'Uploading ${i + 1}/$total: $cleanTitle...',
          ),
        );

        await destRef
            .putFile(file)
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception(
                  'Upload timed out for $cleanTitle. Check internet/Firebase Storage rules.',
                );
              },
            );
        successCount++;
      }

      emit(
        state.copyWith(
          isUploading: false,
          selectedAsset: const [],
          statusMessage: successCount > 0
              ? 'Successfully uploaded $successCount media file(s)!'
              : 'Failed to access selected files for upload.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isUploading: false, statusMessage: 'Upload error: $e'),
      );
    }
  }
}
