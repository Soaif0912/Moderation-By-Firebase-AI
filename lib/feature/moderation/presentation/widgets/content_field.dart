import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moderation_by_firebase_ai/feature/moderation/presentation/bloc/moderation_bloc.dart';
import 'package:moderation_by_firebase_ai/feature/moderation/presentation/bloc/moderation_state.dart';
import 'package:moderation_by_firebase_ai/feature/moderation/presentation/widgets/slected_media_card.dart';

class ContentField extends StatelessWidget {
  const ContentField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModerationBloc, ModerationState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1.r, color: Colors.purple),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: "Type something...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 5,
                minLines: 3,
                style: TextStyle(fontSize: 16.sp),
              ),
              if (state.selectedAsset.isNotEmpty)
                SizedBox(
                  height: 86.h,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: state.selectedAsset.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SelectedMediaCard(
                          asset: state.selectedAsset[index],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
