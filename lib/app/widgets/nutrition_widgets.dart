import 'package:flutter/material.dart';
import 'package:NomAi/app/models/Agent/agent_response.dart';
import 'package:NomAi/app/models/UI/nutrition_ui_models.dart';
import 'package:NomAi/app/services/nutrition_service.dart';
import 'package:NomAi/app/constants/colors.dart';

class NutritionWidgetService {
  /// Builds a nutrition card from response data
  static Widget buildNutritionCard(Response response) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: MealAIColors.whiteText,
        border: Border.all(color: MealAIColors.blackText, width: 1),
        borderRadius: BorderRadius.circular(NutritionUIConstants.cardRadius),
        boxShadow: [
          BoxShadow(
            color: MealAIColors.blackText.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(NutritionUIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(response),
            if (NutritionService.hasNutritionData(response)) ...[
              const SizedBox(height: NutritionUIConstants.sectionSpacing),
              _buildNutritionOverview(response.ingredients!),
              const SizedBox(height: NutritionUIConstants.sectionSpacing),
              if (response.ingredients!.length > 1)
                _buildIngredientsBreakdown(response.ingredients!),
            ],
            const SizedBox(height: NutritionUIConstants.sectionSpacing),
            _buildHealthAssessment(response),
            if (response.primaryConcerns != null &&
                response.primaryConcerns!.isNotEmpty) ...[
              const SizedBox(height: NutritionUIConstants.sectionSpacing),
              _buildHealthConcerns(response.primaryConcerns!),
            ],
            if (response.suggestAlternatives != null &&
                response.suggestAlternatives!.isNotEmpty) ...[
              const SizedBox(height: NutritionUIConstants.sectionSpacing),
              _buildAlternatives(response.suggestAlternatives!),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _buildHeader(Response response) {
    final infoChips = [
      InfoChipItem(
        label: 'Portion',
        value: NutritionService.getPortionDisplayText(response),
      ),
      InfoChipItem(
        label: 'Confidence',
        value: '${response.confidenceScore ?? 0}/10',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: MealAIColors.blackText.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(NutritionUIConstants.smallRadius),
              ),
              child: Icon(
                Icons.analytics,
                color: MealAIColors.blackText,
                size: NutritionUIConstants.iconSize,
              ),
            ),
            const SizedBox(width: NutritionUIConstants.itemSpacing),
            Expanded(
              child: Text(
                response.foodName ?? 'Food Analysis',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: MealAIColors.blackText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: NutritionUIConstants.itemSpacing),
        Wrap(
          spacing: NutritionUIConstants.itemSpacing,
          runSpacing: NutritionUIConstants.smallSpacing,
          children: infoChips.map((chip) => _buildInfoChip(chip)).toList(),
        ),
      ],
    );
  }

  static Widget _buildInfoChip(InfoChipItem chip) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: MealAIColors.greyLight,
        borderRadius: BorderRadius.circular(NutritionUIConstants.chipRadius),
      ),
      child: Text(
        '${chip.label}: ${chip.value}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: MealAIColors.grey,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  static Widget _buildNutritionOverview(List<Ingredient> ingredients) {
    final totals = NutritionService.calculateTotalNutrition(ingredients);
    final nutritionItems = NutritionValueItem.fromTotals(totals);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MealAIColors.blackText.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(NutritionUIConstants.smallRadius),
              ),
              child: Icon(
                Icons.pie_chart,
                color: MealAIColors.blackText,
                size: NutritionUIConstants.iconSize,
              ),
            ),
            const SizedBox(width: NutritionUIConstants.itemSpacing),
            const Expanded(
              child: Text(
                'Nutritional Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MealAIColors.blackText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: NutritionUIConstants.sectionSpacing),
        GridView.count(
          crossAxisCount: NutritionUIConstants.nutritionGridColumns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: NutritionUIConstants.nutritionGridAspectRatio,
          crossAxisSpacing: NutritionUIConstants.nutritionGridSpacing,
          mainAxisSpacing: NutritionUIConstants.nutritionGridSpacing,
          children: nutritionItems
              .map((item) => _buildNutritionValueCard(item))
              .toList(),
        ),
      ],
    );
  }

  static Widget _buildNutritionValueCard(NutritionValueItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MealAIColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MealAIColors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            color: MealAIColors.blackText,
            size: NutritionUIConstants.iconSize,
          ),
          const SizedBox(width: NutritionUIConstants.smallSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: MealAIColors.blackText,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: MealAIColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildIngredientsBreakdown(List<Ingredient> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MealAIColors.blackText.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(NutritionUIConstants.smallRadius),
              ),
              child: Icon(
                Icons.search,
                color: MealAIColors.blackText,
                size: NutritionUIConstants.iconSize,
              ),
            ),
            const SizedBox(width: NutritionUIConstants.itemSpacing),
            const Expanded(
              child: Text(
                'Ingredient Analysis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MealAIColors.blackText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: NutritionUIConstants.sectionSpacing),
        ...ingredients.map((ingredient) => _buildIngredientItem(ingredient)),
      ],
    );
  }

  static Widget _buildIngredientItem(Ingredient ingredient) {
    final healthScore = ingredient.healthScore ?? 0;
    final healthLevel = NutritionService.getHealthScoreLevel(healthScore);
    final config = HealthScoreConfig.fromLevel(healthLevel);

    return Container(
      margin: const EdgeInsets.only(bottom: NutritionUIConstants.itemSpacing),
      padding: const EdgeInsets.all(NutritionUIConstants.cardPadding),
      width: double.infinity,
      decoration: BoxDecoration(
        color: MealAIColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ingredient.name ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: MealAIColors.blackText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: config.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      config.icon,
                      color: MealAIColors.whiteText,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$healthScore/10',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: MealAIColors.whiteText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: NutritionUIConstants.smallSpacing),
          Text(
            'Cal: ${ingredient.calories ?? 0} | Protein: ${ingredient.protein ?? 0}g | Carbs: ${ingredient.carbs ?? 0}g | Fat: ${ingredient.fat ?? 0}g',
            style: TextStyle(
              fontSize: 12,
              color: MealAIColors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (ingredient.healthComments?.isNotEmpty == true) ...[
            const SizedBox(height: NutritionUIConstants.smallSpacing),
            Text(
              ingredient.healthComments!,
              style: const TextStyle(
                fontSize: 12,
                color: MealAIColors.blackText,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildHealthAssessment(Response response) {
    final overallScore = response.overallHealthScore ?? 0;
    final healthLevel = NutritionService.getHealthScoreLevel(overallScore);
    final config = HealthScoreConfig.fromLevel(healthLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: MealAIColors.blackText.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(NutritionUIConstants.smallRadius),
              ),
              child: Icon(
                Icons.health_and_safety,
                color: MealAIColors.blackText,
                size: NutritionUIConstants.iconSize,
              ),
            ),
            const SizedBox(width: NutritionUIConstants.itemSpacing),
            const Expanded(
              child: Text(
                'Health Assessment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MealAIColors.blackText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: NutritionUIConstants.sectionSpacing),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(NutritionUIConstants.cardPadding),
          decoration: BoxDecoration(
            color: config.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: config.color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: config.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          config.icon,
                          color: MealAIColors.whiteText,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Overall Score: $overallScore/10',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: MealAIColors.whiteText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (response.overallHealthComments?.isNotEmpty == true) ...[
                const SizedBox(height: NutritionUIConstants.itemSpacing),
                Text(
                  response.overallHealthComments!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: MealAIColors.blackText,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildHealthConcerns(List<PrimaryConcern> concerns) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MealAIColors.grey.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(NutritionUIConstants.smallRadius),
              ),
              child: Icon(
                Icons.warning,
                color: MealAIColors.grey,
                size: NutritionUIConstants.iconSize,
              ),
            ),
            const SizedBox(width: NutritionUIConstants.itemSpacing),
            const Expanded(
              child: Text(
                'Health Concerns',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MealAIColors.blackText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: NutritionUIConstants.sectionSpacing),
        ...concerns.map((concern) => _buildConcernItem(concern)),
      ],
    );
  }

  static Widget _buildConcernItem(PrimaryConcern concern) {
    return Container(
      margin: const EdgeInsets.only(bottom: NutritionUIConstants.itemSpacing),
      padding: const EdgeInsets.all(NutritionUIConstants.cardPadding),
      width: double.infinity,
      decoration: BoxDecoration(
        color: MealAIColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MealAIColors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            concern.issue ?? 'Health Concern',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: MealAIColors.blackText,
            ),
          ),
          if (concern.explanation?.isNotEmpty == true) ...[
            const SizedBox(height: NutritionUIConstants.smallSpacing),
            Text(
              concern.explanation!,
              style: TextStyle(
                fontSize: 13,
                color: MealAIColors.grey,
                height: 1.4,
              ),
            ),
          ],
          if (concern.recommendations?.isNotEmpty == true) ...[
            const SizedBox(height: NutritionUIConstants.itemSpacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb,
                  color: MealAIColors.blackText,
                  size: NutritionUIConstants.smallIconSize,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recommendations:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: MealAIColors.blackText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...concern.recommendations!.map(
                        (rec) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '• ${rec.food ?? ''} (${rec.quantity ?? ''}): ${rec.reasoning ?? ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: MealAIColors.grey,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildAlternatives(List<Ingredient> alternatives) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MealAIColors.blackText.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(NutritionUIConstants.smallRadius),
              ),
              child: Icon(
                Icons.swap_horiz,
                color: MealAIColors.blackText,
                size: NutritionUIConstants.iconSize,
              ),
            ),
            const SizedBox(width: NutritionUIConstants.itemSpacing),
            const Expanded(
              child: Text(
                'Healthier Alternatives',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MealAIColors.blackText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: NutritionUIConstants.sectionSpacing),
        ...alternatives
            .map((alternative) => _buildAlternativeItem(alternative)),
      ],
    );
  }

  static Widget _buildAlternativeItem(Ingredient alternative) {
    final healthScore = alternative.healthScore ?? 0;
    final healthLevel = NutritionService.getHealthScoreLevel(healthScore);
    final config = HealthScoreConfig.fromLevel(healthLevel);

    return Container(
      margin: const EdgeInsets.only(bottom: NutritionUIConstants.itemSpacing),
      padding: const EdgeInsets.all(NutritionUIConstants.cardPadding),
      width: double.infinity,
      decoration: BoxDecoration(
        color: MealAIColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MealAIColors.blackText.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  alternative.name ?? 'Alternative',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: MealAIColors.blackText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: config.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$healthScore/10',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: MealAIColors.whiteText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NutritionUIConstants.smallSpacing),
          Text(
            'Cal: ${alternative.calories ?? 0} | Protein: ${alternative.protein ?? 0}g | Carbs: ${alternative.carbs ?? 0}g | Fat: ${alternative.fat ?? 0}g',
            style: TextStyle(
              fontSize: 12,
              color: MealAIColors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (alternative.healthComments?.isNotEmpty == true) ...[
            const SizedBox(height: NutritionUIConstants.smallSpacing),
            Text(
              alternative.healthComments!,
              style: const TextStyle(
                fontSize: 12,
                color: MealAIColors.blackText,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
