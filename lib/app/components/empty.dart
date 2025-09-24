import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:sizer/sizer.dart';

class EmptyIllustrations extends StatelessWidget {
  final String title;
  final String message;
  final String imagePath;
  final Color color;
  final double? height;
  final double? width;
  final bool removeHeightValue;
  final double? imageHeight;
  final TextStyle? headerTextStyle;
  final TextStyle? contentTextStyle;
  final bool placeInCenter;

  const EmptyIllustrations({
    Key? key,
    required this.title,
    required this.message,
    this.imagePath = "assets/svg/empty.svg",
    this.color = Colors.transparent,
    this.height,
    this.width,
    this.imageHeight,
    this.headerTextStyle,
    this.contentTextStyle,
    this.removeHeightValue = false,
    this.placeInCenter = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: placeInCenter ? 50.h : 0),
      width: 100.w,
      decoration: BoxDecoration(color: color),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: imageHeight,
            child: SvgPicture.asset(
              imagePath,
              width: width,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              // style: (headerTextStyle ?? context.subtitle1)
              //     .copyWith(color: FeatsColors.dark),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            width: width ?? 80.w,
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.sp, 0, 8.sp, 0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                // style: (contentTextStyle ?? context.subtitle2)
                //     .copyWith(color: FeatsColors.dark),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OrgIllustrationText extends StatelessWidget {
  final String title;
  final String message;
  final Color color;
  final double? height;
  final double? width;
  final double? imageHeight;
  final TextStyle? headerTextStyle;
  final TextStyle? contentTextStyle;

  const OrgIllustrationText({
    Key? key,
    required this.title,
    required this.message,
    this.color = Colors.transparent,
    this.height,
    this.width,
    this.imageHeight,
    this.headerTextStyle,
    this.contentTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 3.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              // style: (headerTextStyle ?? context.subtitle1)
              //     .copyWith(color: FeatsColors.dark),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            width: width ?? 80.w,
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.sp, 0, 8.sp, 0),
              child: Text(
                message,
                maxLines: 3,
                textAlign: TextAlign.center,
                // style: (contentTextStyle ?? context.subtitle2)
                //     .copyWith(color: FeatsColors.dark),
              ),
            ),
          )
        ],
      ),
    );
  }
}
