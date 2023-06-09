import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/utils.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../core/constants/constants.dart';
import '../../../models/community_model.dart';
import '../../../responsive/responsive.dart';
import '../../../theme/pallete.dart';
import '../../../widgets/custom_text.dart';
import '../controller/community_controller.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({required this.name, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerImage;
  File? profileImage;
  Uint8List? bannerWebFile;
  Uint8List? profileWebFile;
  void selectBannerImage() async {
    final res = await pickImage();

    if (res != null) {
      if (kIsWeb) {
        setState(() {
          bannerWebFile = res.files.first.bytes;
        });
      } else {
        setState(() {
          bannerImage = File(res.files.first.path!);
        });
      }
    }
  }

  void selectProfileImage() async {
    final res = await pickImage();

    if (res != null) {
      if (kIsWeb) {
        setState(() {
          profileWebFile = res.files.first.bytes;
        });
      } else {
        setState(() {
          profileImage = File(res.files.first.path!);
        });
      }
    }
  }

  void save(Community community) {
    ref.read(communityControllerProvider.notifier).editCommunity(
          community: community,
          profileFile: profileImage,
          bannerFile: bannerImage,
          context: context,
          profileWebFile: profileWebFile,
          bannerWebFile: bannerWebFile,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    return ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (community) => Scaffold(
            backgroundColor: currentTheme.colorScheme.background,
            appBar: AppBar(
              centerTitle: true,
              title: const CustomText(text: "Edit Community"),
              actions: [
                TextButton(
                    onPressed: () => save(community),
                    child: const CustomText(text: "Save"))
              ],
            ),
            body: isLoading
                ? const Loader()
                : Responsive(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 200,
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: selectBannerImage,
                                    child: DottedBorder(
                                      borderType: BorderType.RRect,
                                      dashPattern: const [10, 4],
                                      strokeCap: StrokeCap.round,
                                      radius: const Radius.circular(10),
                                      color: currentTheme
                                          .textTheme.bodyMedium!.color!,
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 150,
                                        child: bannerWebFile != null
                                            ? Image.memory(bannerWebFile!)
                                            : bannerImage != null
                                                ? Image.file(bannerImage!)
                                                : community.banner.isEmpty ||
                                                        community.banner ==
                                                            Constants
                                                                .bannerDefault
                                                    ? const Center(
                                                        child: Icon(
                                                          Icons
                                                              .camera_alt_outlined,
                                                          size: 40,
                                                        ),
                                                      )
                                                    : Image.network(
                                                        community.banner),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    left: 20,
                                    child: GestureDetector(
                                      onTap: selectProfileImage,
                                      child: profileImage != null
                                          ? CircleAvatar(
                                              backgroundImage:
                                                  MemoryImage(profileWebFile!),
                                              radius: 32,
                                            )
                                          : profileImage != null
                                              ? CircleAvatar(
                                                  backgroundImage:
                                                      FileImage(profileImage!),
                                                  radius: 32,
                                                )
                                              : CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      community.avatar),
                                                  radius: 32,
                                                ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
