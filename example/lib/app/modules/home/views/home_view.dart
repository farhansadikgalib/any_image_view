import 'package:any_image_view/any_image_view.dart';
import 'package:example/generated/assets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Any Image View Example',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent),
      body: ListView(
        children: <Widget>[

          const SizedBox(
            height: 20,
          ),
          AnyImageView(
            imagePath: 'https://picsum.photos/250?image=0',
            height: 200,
            width: 300,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            borderRadius: BorderRadius.circular(10),
            cachedNetHeight: 30,
            cachedNetWidth: 30,
            boxFit: BoxFit.contain,
            alignment: Alignment.center,
            onTap: () {
              print('image tapped');
            },
            errorPlaceHolder: 'assets/png/car.png',
          ),
          const SizedBox(
            height: 20,
          ),
          AnyImageView(
            padding: const EdgeInsets.all(30),
            imagePath: Assets.pngCar,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 50,
            onTap: () {
              if (kDebugMode) {
                print('image tapped');
              }
            },
          ),
          const SizedBox(
            height: 20,
          ),
          AnyImageView(
            imagePath: Assets.lottieOffer,
            height: 100,
            width: 100,
            onTap: () {
              if (kDebugMode) {
                print('image tapped');
              }
            },
          ),
          AnyImageView()
        ],
      ),
    );
  }
}
