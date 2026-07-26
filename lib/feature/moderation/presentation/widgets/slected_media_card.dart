import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moderation_by_firebase_ai/feature/moderation/presentation/bloc/moderation_bloc.dart';
import 'package:moderation_by_firebase_ai/feature/moderation/presentation/bloc/moderation_event.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class SelectedMediaCard extends StatelessWidget {
  final AssetEntity? asset;

  const SelectedMediaCard({super.key, this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.w,
      height: 70.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(width: 1.r, color: Colors.purple),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (asset != null) ...[
              Image(
                image: AssetEntityImageProvider(
                  asset!,
                  isOriginal: false,
                  thumbnailSize: const ThumbnailSize.square(200),
                ),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
              ),
              Positioned(
                top: 2.r,
                right: 2.r,
                child: GestureDetector(
                  onTap: () {
                    context.read<ModerationBloc>().add(
                      SelectAssetEvent(asset!),
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(2.r),
                    child: Icon(Icons.close, color: Colors.white, size: 14.r),
                  ),
                ),
              ),
              Center(
                child: Icon(
                  asset!.type == AssetType.image
                      ? Icons.image
                      : asset!.type == AssetType.video
                      ? Icons.play_arrow
                      : null,
                  color: Colors.white,
                  size: 24.r,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
