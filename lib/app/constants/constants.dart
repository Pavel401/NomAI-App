import 'dart:math';

class AppConstants {
  static String appName = "MealAI";

  static final List<String> nutritionFunFacts = [
    "Drinking water before meals can help you eat fewer calories and may be effective for weight loss.",
    "Protein can boost your metabolism by 80-100 calories per day and make you automatically eat fewer calories.",
    "Chili peppers contain capsaicin, which can boost metabolism and reduce appetite slightly.",
    "Fiber-rich foods can help with weight loss by increasing fullness and reducing calorie absorption.",
    "Leafy greens are among the most nutrient-dense foods, providing vitamins, minerals, and antioxidants with very few calories.",
    "Eating slowly can help you feel more full and lose weight while eating less.",
    "Including protein at breakfast can help reduce cravings and calorie intake throughout the day.",
    "Whole eggs are among the most nutritious foods on the planet, containing a little bit of almost every nutrient you need.",
    "Vegetables are high in fiber and nutrients but low in calories, making them perfect for weight loss.",
    "Nuts, despite being high in fat, are not associated with weight gain and can help improve metabolic health.",
    "Berries are among the most antioxidant-rich foods and can help improve blood sugar regulation.",
    "Fermented foods like yogurt and kimchi contain probiotics that can improve gut health and may help with weight management.",
    "Oily fish such as salmon provide high-quality protein and omega-3 fatty acids that can reduce inflammation and support heart health.",
    "Cinnamon can help lower blood sugar and has powerful anti-inflammatory properties.",
    "Dark chocolate is rich in antioxidants and can help improve heart health when consumed in moderation.",
    "Greek yogurt contains more protein than regular yogurt and supports muscle growth and satiety.",
    "Legumes like beans, lentils, and chickpeas are excellent plant-based protein sources and help regulate blood sugar.",
    "Avocados are nutrient-dense, rich in heart-healthy monounsaturated fats, and can help with weight management.",
    "Green tea contains catechins and caffeine, which can boost metabolism and support fat burning.",
    "Turmeric, thanks to curcumin, has strong anti-inflammatory and antioxidant properties that support brain and heart health.",
    "Quinoa is a complete protein, containing all nine essential amino acids, making it a great option for vegetarians.",
    "Almonds and other nuts provide vitamin E, magnesium, and healthy fats, supporting brain and heart health.",
    "Flaxseeds and chia seeds are rich in fiber, omega-3s, and lignans, which may help lower cholesterol and support digestion.",
    "Bone broth is a good source of collagen and amino acids, which can promote gut health and joint support.",
    "Coffee in moderation may enhance cognitive function and metabolism due to its caffeine and antioxidant content.",
    "Beets contain nitrates that can improve blood flow and endurance performance.",
    "Garlic has potent anti-inflammatory and immune-boosting properties, helping to lower blood pressure and cholesterol.",
    "Coconut oil contains medium-chain triglycerides (MCTs), which may increase calorie burning and energy levels.",
    "Kimchi and sauerkraut are rich in probiotics, which support gut microbiome diversity and digestion.",
    "Watermelon is hydrating and contains citrulline, which may help improve blood circulation.",
    "Broccoli is high in sulforaphane, a compound with potential anti-cancer properties.",
    "Mushrooms provide vitamin D when exposed to sunlight and contain compounds that may support immune function.",
    "Egg yolks are rich in choline, an essential nutrient for brain and liver health.",
    "Sweet potatoes are a great source of beta-carotene, which supports eye health and immune function."
  ];

  static String getRandomFunFact() {
    final random = Random();
    return nutritionFunFacts[random.nextInt(nutritionFunFacts.length)];
  }
}

class AppInfo {
  static String appName = "MealAI";

  static String appDescription =
      "MealAI is an AI-powered nutrition app that helps you get healthier by providing personalized meal plans and nutrition advice.";
}
