import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/core/common/constants/launch_url.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class AdSlider extends StatelessWidget {
  const AdSlider({
    super.key,
    required this.homeApiProvider,
  });

  final HomeApiProvider homeApiProvider;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height:
            homeApiProvider.homeDataList.first.sliders.isNotEmpty ? 90.0 : 0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
      ),
      items: homeApiProvider.homeDataList.first.sliders.map((slider) {
        return Builder(
          builder: (BuildContext context) {
            return ZoomTapAnimation(
              onTap: () {
                urlLauncher((slider.link?.trim().isNotEmpty == true)
                    ? slider.link!
                    : 'https://inteshar.net/');
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.all(5.0),
                height: 90,
                clipBehavior: Clip.antiAlias,
                decoration: Constants.intesharBoxDecoration(context),
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  height: 90,
                  width: double.infinity,
                  imageUrl: slider.photoUrl ?? '',
                  placeholder: (context, url) => const CustomLoading(),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/not.jpg',
                    fit: BoxFit.fill,
                    height: 90,
                    width: double.infinity,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
