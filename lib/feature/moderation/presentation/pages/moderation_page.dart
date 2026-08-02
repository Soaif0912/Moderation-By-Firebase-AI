import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moderation_by_firebase_ai/feature/moderation/presentation/widgets/content_field.dart';
import 'package:moderation_by_firebase_ai/feature/moderation/presentation/widgets/media_manager.dart';

import '../bloc/moderation_bloc.dart';
import '../bloc/moderation_event.dart';
import '../bloc/moderation_state.dart';

class ModerationPage extends StatelessWidget {
  const ModerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ModerationBloc()..add(const FetchMediaEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Moderation Page'), centerTitle: true),
        body: const ModerationBody(),
        bottomNavigationBar: BlocBuilder<ModerationBloc, ModerationState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.only(
                top: 15.h,
                left: 20.w,
                right: 20.w,
                bottom: 25.h,
              ),
              child: ElevatedButton(
                onPressed: state.isUploading || state.selectedAsset.isEmpty
                    ? null
                    : () {
                        context.read<ModerationBloc>().add(
                          const UploadMediaEvent(),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: state.isUploading
                    ? SizedBox(
                        height: 22.h,
                        width: 22.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        state.selectedAsset.isEmpty
                            ? 'Check Result'
                            : 'Upload Selected (${state.selectedAsset.length})',
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ModerationBody extends StatelessWidget {
  const ModerationBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModerationBloc, ModerationState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ContentField(),
              SizedBox(height: 20.h),
              const Expanded(child: MediaManager()),
            ],
          ),
        );
      },
    );
  }
}
