// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'package:inteshar/app/config/constants.dart';
// import 'package:inteshar/app/config/functions.dart';
// import 'package:inteshar/app/core/utils/custom_loading.dart';
// import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';

// class WalletCard extends StatelessWidget {
//   const WalletCard({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final HomeApiProvider updateController = Get.find<HomeApiProvider>();
//     return Obx(
//       () {
//         if (updateController.homeDataList.isEmpty) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//         final user = updateController.homeDataList.first;
// //
//         return Container(
//           height: 200,
//           width: Get.width,
//           padding: const EdgeInsets.all(20),
//           alignment: Alignment.center,
//           decoration: Constants.intesharBoxDecoration(context).copyWith(
//             image: DecorationImage(
//               image: const AssetImage(
//                 'assets/images/bg-v-card.png',
//               ),
//               colorFilter: ColorFilter.mode(
//                   Theme.of(context).colorScheme.primary, BlendMode.color),
//               fit: BoxFit.fill,
//             ),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Main widget
//               ColorFiltered(
//                 colorFilter: ColorFilter.mode(
//                   Theme.of(context).colorScheme.onPrimary,
//                   BlendMode.srcIn,
//                 ),
//                 child: LayoutBuilder(
//                   builder: (context, constraints) {
//                     return CachedNetworkImage(
//                       fit: BoxFit.cover,
//                       height: 70,
//                       width: null,
//                       imageUrl: user.user?.agent?.appPhotoUrl ?? '',
//                       placeholder: (context, url) => const CustomLoading(),
//                       errorWidget: (context, url, error) => Image.asset(
//                         'assets/images/defultLogo.png',
//                         fit: BoxFit.fill,
//                         height: 70,
//                         width: null,
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               Text(
//                 user.user?.name ?? '',
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.onPrimary,
//                   fontSize: 17,
//                 ),
//               ),
//               const Gap(10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       '      رصيدك',
//                       style: TextStyle(
//                         color: Theme.of(context).colorScheme.onPrimary,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                   Text(
//                     formatNumber(user.user?.totalBalance ?? 000) ?? '',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.onPrimary,
//                       fontSize: 25,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       '    IQD',
//                       style: TextStyle(
//                         color: Theme.of(context).colorScheme.onPrimary,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
