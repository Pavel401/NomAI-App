import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:davinci/davinci.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/models/AI/nutrition_record.dart';
import 'package:NomAi/app/models/AI/nutrition_output.dart';
import 'package:NomAi/app/utility/date_utility.dart';
import 'package:NomAi/app/components/dialogs.dart';

class SocialMediaShareWidget extends StatefulWidget {
  final NutritionRecord nutritionRecord;
  final String? userName;

  const SocialMediaShareWidget({
    Key? key,
    required this.nutritionRecord,
    this.userName,
  }) : super(key: key);

  @override
  State<SocialMediaShareWidget> createState() => _SocialMediaShareWidgetState();
}

class _SocialMediaShareWidgetState extends State<SocialMediaShareWidget> {
  GlobalKey? imageKey;
  bool _isGenerating = false;
  Uint8List? imageData;
  File? imageFile;

  /// [getFile] returns the File from Uint8List data
  Future getFile(Uint8List u8Image, String imageName) async {
    /// getting the temp directory of the app.
    String dir = (await getApplicationDocumentsDirectory()).path;

    /// Saving the file with the file name in temp directory.
    File file = File('$dir/$imageName.png');

    /// the image file is created
    await file.writeAsBytes(u8Image);

    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealAIColors.whiteText,
      appBar: AppBar(
        backgroundColor: MealAIColors.whiteText,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: MealAIColors.blackText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Share Your Meal',
          style: TextStyle(
            color: MealAIColors.blackText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (!_isGenerating)
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: ElevatedButton.icon(
                onPressed: _handleShare,
                icon:
                    Icon(Icons.share, color: MealAIColors.whiteText, size: 18),
                label: Text(
                  'Share',
                  style: TextStyle(
                    color: MealAIColors.whiteText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MealAIColors.blackText,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Davinci(
            builder: (key) {
              imageKey = key;
              return _buildShareableWidget();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShareableWidget() {
    final response = widget.nutritionRecord.nutritionOutput?.response;
    if (response == null) return const SizedBox();

    // Calculate totals
    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    if (response.ingredients != null) {
      for (var ingredient in response.ingredients!) {
        totalCalories += ingredient.calories ?? 0;
        totalProtein += ingredient.protein ?? 0;
        totalCarbs += ingredient.carbs ?? 0;
        totalFat += ingredient.fat ?? 0;
      }
    }

    return Container(
      width: 90.w,
      constraints: BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: MealAIColors.whiteText,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MealAIColors.blackText.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MealAIColors.blackText.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section
          _buildHeader(),

          // Food image section - only show if image exists
          if (widget.nutritionRecord.nutritionInputQuery?.imageUrl != null &&
              widget.nutritionRecord.nutritionInputQuery!.imageUrl!.isNotEmpty)
            _buildFoodImageSection(),

          // Food info section
          _buildFoodInfoSection(response, totalCalories),

          // Nutrition breakdown
          _buildNutritionBreakdown(
              totalCalories, totalProtein, totalCarbs, totalFat),

          // Health score section
          if (response.overallHealthScore != null)
            _buildHealthScoreSection(response.overallHealthScore!),

          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: MealAIColors.blackText,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MealAIColors.whiteText,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant_menu,
              color: MealAIColors.blackText,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NomAI',
                  style: TextStyle(
                    color: MealAIColors.whiteText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'AI Nutrition Tracking',
                  style: TextStyle(
                    color: MealAIColors.whiteText.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (widget.userName != null)
            Text(
              '@${widget.userName}',
              style: TextStyle(
                color: MealAIColors.whiteText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFoodImageSection() {
    return Container(
      height: 180,
      width: double.infinity,
      margin: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MealAIColors.blackText.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: widget.nutritionRecord.nutritionInputQuery!.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: MealAIColors.lightGreyTile,
                child: Center(
                  child: CircularProgressIndicator(
                    color: MealAIColors.blackText.withOpacity(0.5),
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) =>
                  const SizedBox.shrink(), // Return empty widget on error
            ),

            // Time stamp
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: MealAIColors.blackText.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateUtility.getTimeFromDateTime(
                    widget.nutritionRecord.recordTime?.toLocal() ??
                        DateTime.now(),
                  ),
                  style: TextStyle(
                    color: MealAIColors.whiteText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodInfoSection(NutritionResponse response, int totalCalories) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          Text(
            response.foodName ?? 'Unknown Food',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: MealAIColors.blackText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: MealAIColors.blackText,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$totalCalories calories',
              style: TextStyle(
                color: MealAIColors.whiteText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionBreakdown(
      int calories, int protein, int carbs, int fat) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: MealAIColors.lightGreyTile,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Nutrition Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: MealAIColors.blackText,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildNutrientColumn(
                  'Protein',
                  '${protein}g',
                  Icons.fitness_center,
                ),
              ),
              Expanded(
                child: _buildNutrientColumn(
                  'Carbs',
                  '${carbs}g',
                  Icons.grain,
                ),
              ),
              Expanded(
                child: _buildNutrientColumn(
                  'Fat',
                  '${fat}g',
                  Icons.water_drop,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: MealAIColors.blackText,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: MealAIColors.whiteText, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: MealAIColors.blackText.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: MealAIColors.blackText,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthScoreSection(int healthScore) {
    String scoreText = _getHealthScoreText(healthScore);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: MealAIColors.lightGreyTile,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MealAIColors.blackText.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MealAIColors.blackText,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.favorite,
              color: MealAIColors.whiteText,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Score',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MealAIColors.blackText.withOpacity(0.7),
                  ),
                ),
                Text(
                  '$healthScore/10 - $scoreText',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MealAIColors.blackText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: MealAIColors.lightGreyTile,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smartphone,
            size: 14,
            color: MealAIColors.blackText.withOpacity(0.6),
          ),
          SizedBox(width: 1.w),
          Text(
            'Track your nutrition with NomAI',
            style: TextStyle(
              fontSize: 12,
              color: MealAIColors.blackText.withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  String _getHealthScoreText(int score) {
    if (score >= 8) return 'Excellent';
    if (score >= 6) return 'Good';
    if (score >= 4) return 'Fair';
    return 'Poor';
  }

  Future<void> _handleShare() async {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
    });

    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    AppDialogs.showLoadingDialog(
      title: "Generating Share Image",
      message: "Creating your beautiful meal card...",
    );

    try {
      imageData = await DavinciCapture.click(
        context: context,
        imageKey!,
        fileName: "MealShare",
        pixelRatio: pixelRatio,
        returnImageUint8List: true,
        openFilePreview: false,
      );

      imageFile = await getFile(
        imageData!,
        "MealShare",
      );

      AppDialogs.hideDialog();

      // Share using share_plus
      try {
        final response = widget.nutritionRecord.nutritionOutput?.response;
        String foodName = response?.foodName ?? "My delicious meal";

        // Calculate nutrition totals for the share message
        int totalCalories = 0;
        int totalProtein = 0;
        int totalCarbs = 0;
        int totalFat = 0;

        if (response?.ingredients != null) {
          for (var ingredient in response!.ingredients!) {
            totalCalories += ingredient.calories ?? 0;
            totalProtein += ingredient.protein ?? 0;
            totalCarbs += ingredient.carbs ?? 0;
            totalFat += ingredient.fat ?? 0;
          }
        }

        String shareText = '''🍽️ Just tracked "$foodName" with NomAI! 

📊 Nutrition breakdown:
• $totalCalories calories
• ${totalProtein}g protein
• ${totalCarbs}g carbs  
• ${totalFat}g fat

🤖 AI-powered nutrition tracking made simple! Get instant nutrition analysis from just a photo.

📱 Download NomAI: https://play.google.com/store/apps/details?id=com.nomai.app

#NomAI #NutritionTracking #HealthyEating #AInutrition #FoodTracking #HealthTech''';

        Share.shareXFiles(
          [XFile(imageFile!.path)],
          text: shareText,
        );
      } catch (error) {
        AppDialogs.showErrorSnackbar(
          title: "Share Failed",
          message: "Unable to share your meal. Please try again.",
        );
      }
    } catch (e) {
      AppDialogs.hideDialog();
      AppDialogs.showErrorSnackbar(
        title: "Error",
        message: "Failed to generate share image. Please try again.",
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }
}
