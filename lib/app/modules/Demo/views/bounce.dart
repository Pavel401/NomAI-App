import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';

class AppStoreView extends StatelessWidget {
  const AppStoreView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 60, 25, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "WEDNESDAY 29 SEPTEMBER",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  Bounceable(
                    onTap: () {},
                    scaleFactor: 0.6,
                    child: const Icon(
                      CupertinoIcons.person_crop_circle,
                      color: Colors.blueAccent,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const _AppStoreCard(
                imageUrl:
                    "https://cdn.redmondpie.com/wp-content/uploads/2021/06/ios-15-wallpapers-download-1200.jpg",
                leading: "Get started",
                title: "What's new for apps in iOS 15",
                description:
                    "Safari extension, Focus, notification summary and more.",
              ),
              const SizedBox(height: 30),
              const _AppStoreCard(
                imageUrl:
                    "https://c0.wallpaperflare.com/preview/287/852/868/adult-black-and-white-boy-dark.jpg",
                leading: "Get creative",
                title: "Learn to play guitar with these 3 steps",
                description: "Apps to make life better. Tap for more.",
              ),
              const SizedBox(height: 30),
              const _AppStoreCard(
                imageUrl:
                    "https://www.apple.com/v/ipad-pro/ag/images/overview/experience/intro_display_posterframe__fht01wiilnyq_large.jpg",
                leading: "New features",
                title: "Top updates this week",
                description:
                    "Safari extension, Focus, notification summary and more.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppStoreCard extends StatelessWidget {
  final String imageUrl;
  final String leading;
  final String title;
  final String description;

  const _AppStoreCard({
    Key? key,
    required this.imageUrl,
    required this.leading,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: () {},
      child: PhysicalModel(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
        elevation: 20,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  height: 400,
                ),
              ),
              Container(
                height: 400,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leading.toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey[200],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
