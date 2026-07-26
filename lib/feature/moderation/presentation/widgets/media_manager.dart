import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moderation_by_firebase_ai/feature/moderation/presentation/bloc/moderation_bloc.dart';
import 'package:moderation_by_firebase_ai/feature/moderation/presentation/bloc/moderation_event.dart';
import 'package:moderation_by_firebase_ai/feature/moderation/presentation/bloc/moderation_state.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class MediaManager extends StatelessWidget {
  const MediaManager({super.key});

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModerationBloc, ModerationState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            border: Border.all(width: 1.r, color: Colors.purple),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Device Media',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: () {
                          context.read<ModerationBloc>().add(
                            const FetchMediaEvent(),
                          );
                        },
                        tooltip: 'Refresh',
                      ),
                      if (state.albums.isNotEmpty)
                        DropdownButton<AssetPathEntity>(
                          value: state.selectedAlbum,
                          underline: Divider(color: Colors.black, height: 1.h),
                          isDense: true,
                          items: state.albums.map((album) {
                            return DropdownMenuItem<AssetPathEntity>(
                              value: album,
                              child: Text(
                                album.name.isEmpty ? 'Recent' : album.name,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            );
                          }).toList(),
                          onChanged: (album) {
                            if (album != null) {
                              context.read<ModerationBloc>().add(
                                ChangeAlbumEvent(album),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5.h),
              Text(
                state.statusMessage,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 10.h),
              Expanded(child: _buildMediaContent(context, state)),
              if (state.selectedAsset.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.collections, color: Colors.purple, size: 20.r),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Selected: ${state.selectedAsset.length} items',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.purple.shade900,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          context.read<ModerationBloc>().add(
                            const ClearSelectedAssetEvent(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaContent(BuildContext context, ModerationState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.permissionState.isAuth && !state.permissionState.hasAccess) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 48.r, color: Colors.grey),
            SizedBox(height: 8.h),
            Text(
              'Permission required to access device photos & videos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<ModerationBloc>().add(const FetchMediaEvent());
                  },
                  child: const Text('Grant Access'),
                ),
                SizedBox(width: 8.w),
                OutlinedButton(
                  onPressed: () {
                    PhotoManager.openSetting();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (state.assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.perm_media_outlined, size: 40.r, color: Colors.grey),
            SizedBox(height: 8.h),
            Text(
              'No images or videos found on device.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ModerationBloc>().add(const FetchMediaEvent());
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: state.assets.length,
      itemBuilder: (context, index) {
        final asset = state.assets[index];
        final isSelected = state.selectedAsset.any((a) => a.id == asset.id);

        return GestureDetector(
          onTap: () {
            context.read<ModerationBloc>().add(SelectAssetEvent(asset));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: isSelected
                  ? Border.all(color: Colors.purple, width: 3.r)
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isSelected ? 5.r : 8.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: AssetEntityImageProvider(
                      asset,
                      isOriginal: false,
                      thumbnailSize: const ThumbnailSize.square(300),
                    ),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  if (asset.type == AssetType.video)
                    Positioned(
                      bottom: 4.h,
                      right: 4.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 12.r,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              _formatDuration(asset.duration),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isSelected)
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(2.r),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14.r,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
