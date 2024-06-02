import 'package:ellenox_hackathon/views/chatbot.dart';
import 'package:ellenox_hackathon/constants/colors.dart';
import 'package:ellenox_hackathon/constants/images.dart';
import 'package:ellenox_hackathon/models/text_with_bg_deco.dart';
import 'package:ellenox_hackathon/utils/utils.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color2,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Travel Genie",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 50,
          ),
          Image.asset(
            AppImages.splash,
            width: double.infinity,
            height: 360,
            fit: BoxFit.cover,
          ),
          const SizedBox(
            height: 30,
          ),
          const TextWithBgDeco(
            text: "Let's Explore",
          ),
          // Text(
          //   "Travel Plan",
          //   style: TextStyle(
          //     fontSize: 40,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          const SizedBox(
            height: 6,
          ),
          const Text(
            "Travel anywhere in the",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
          const Text(
            "world without any hussle",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 70,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(AppColors.color4),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
                      horizontal: 70, vertical: 15))),
              onPressed: () {
                Utils.navigate(context, Home());
              },
              child: Text(
                "Get started",
                style: TextStyle(
                    color: AppColors.color17,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ))
        ],
      ),
    );
  }
}
