import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/repository/community_repository.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/utils.dart';
import '../../../models/community_model.dart';

final userCommunityStreamProvider = StreamProvider<List<Community>>((ref) {
  final controllerProvider = ref.read(communityControllerProvider.notifier);

  return controllerProvider.getUserCommunties();
});
final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  return CommunityController(
      communityRepository: ref.read(communityRepositoryProvider), ref: ref);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  CommunityController(
      {required CommunityRepository communityRepository, required Ref ref})
      : _ref = ref,
        _communityRepository = communityRepository,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true; //loading is set to true
    final uid = _ref.read(userProvider)?.uid ?? '';
    //Uid of the user is there or not (whether user is logged in or not)
    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [
        uid
      ], //Whatever members are there will be stored in the form of list
      mods: [uid], //UID of moderators
    );
    final res = await _communityRepository.createCommunity(community);
    state = false; //loading is set to false
    res.fold((l) => showSnackBar(context: context, message: l.message), (r) {
      showSnackBar(context: context, message: 'Community created successfully');
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Community>> getUserCommunties() {
    var user = _ref.read(userProvider);
    return _communityRepository.getUserCommunities(user!.uid);
  }
}