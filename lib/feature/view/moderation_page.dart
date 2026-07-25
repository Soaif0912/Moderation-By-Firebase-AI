import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class ModerationPage extends StatelessWidget {
  const ModerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderation Page'),
        centerTitle: true,
      ),
      body: const ModerationBody(),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          top: 15.h,
          left: 20.w,
          right: 20.w,
          bottom: 25.h,
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 48.h),
          ),
          child: const Text('Check Result'),
        ),
      ),
    );
  }
}

class ModerationBody extends StatefulWidget {
  const ModerationBody({super.key});

  @override
  State<ModerationBody> createState() => _ModerationBodyState();
}

class _ModerationBodyState extends State<ModerationBody> {
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _selectedAlbum;
  List<AssetEntity> _assets = [];
  AssetEntity? _selectedAsset;
  bool _isLoading = true;
  PermissionState _permissionState = PermissionState.notDetermined;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMedia();
  }

  Future<void> _fetchMedia() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting permission...';
    });

    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      _permissionState = ps;

      if (ps.isAuth || ps.hasAccess) {
        setState(() {
          _statusMessage = 'Loading albums...';
        });

        final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
          type: RequestType.common,
          hasAll: true,
        );

        if (albums.isNotEmpty) {
          _albums = albums;
          _selectedAlbum = albums.first;
          final List<AssetEntity> assets = await _selectedAlbum!.getAssetListRange(
            start: 0,
            end: 100,
          );
          _assets = assets;
          _statusMessage = 'Found ${assets.length} items in "${_selectedAlbum!.name}"';
        } else {
          _albums = [];
          _assets = [];
          _statusMessage = 'No albums found on device';
        }
      } else {
        _statusMessage = 'Permission state: ${ps.name}. Permission not granted.';
      }
    } catch (e) {
      _statusMessage = 'Error loading media: $e';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onAlbumChanged(AssetPathEntity? album) async {
    if (album == null) return;
    setState(() {
      _selectedAlbum = album;
      _isLoading = true;
      _statusMessage = 'Loading ${album.name}...';
    });

    try {
      final List<AssetEntity> assets = await album.getAssetListRange(
        start: 0,
        end: 100,
      );
      if (mounted) {
        setState(() {
          _assets = assets;
          _isLoading = false;
          _statusMessage = 'Found ${assets.length} items in "${album.name}"';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Error loading album: $e';
        });
      }
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Type something...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            maxLines: 5,
            minLines: 3,
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: Container(
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
                            onPressed: _fetchMedia,
                            tooltip: 'Refresh',
                          ),
                          if (_albums.isNotEmpty)
                            DropdownButton<AssetPathEntity>(
                              value: _selectedAlbum,
                              underline: const SizedBox(),
                              isDense: true,
                              items: _albums.map((album) {
                                return DropdownMenuItem<AssetPathEntity>(
                                  value: album,
                                  child: Text(
                                    album.name.isEmpty ? 'Recent' : album.name,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                );
                              }).toList(),
                              onChanged: _onAlbumChanged,
                            ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    _statusMessage,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: _buildMediaContent(),
                  ),
                  if (_selectedAsset != null) ...[
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedAsset!.type == AssetType.video
                                ? Icons.videocam
                                : Icons.image,
                            color: Colors.purple,
                            size: 20.r,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Selected: ${_selectedAsset!.title ?? _selectedAsset!.id}',
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
                              setState(() {
                                _selectedAsset = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_permissionState.isAuth && !_permissionState.hasAccess) {
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
                  onPressed: _fetchMedia,
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

    if (_assets.isEmpty) {
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
            SizedBox(height: 4.h),
            Text(
              'Make sure your device/emulator gallery has photos or videos.',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: _fetchMedia,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry Fetch'),
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
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        final isSelected = _selectedAsset?.id == asset.id;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAsset = isSelected ? null : asset;
            });
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
                        child: const Icon(Icons.broken_image, color: Colors.grey),
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
