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
      final PermissionState ps = await PhotoManager.requestPermissionExtend();

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
            );

        if (albums.isNotEmpty) {
          final selectedAlbum = albums.first;
          final List<AssetEntity> assets = await selectedAlbum
              .getAssetListRange(start: 0, end: 100);

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
              statusMessage: 'No albums found on device',
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
}
