import 'package:flutter/material.dart';
import 'package:turfit/app/models/AI/nutrition_record.dart';

class NutritionView extends StatelessWidget {
  final NutritionRecord nutritionRecord;

  const NutritionView({super.key, required this.nutritionRecord});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          'Nutrition Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Display
              Center(
                child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: nutritionRecord.nutritionInputQuery!.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            nutritionRecord.nutritionInputQuery!.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.black),
                                    SizedBox(height: 8),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Text(
                            'No Image Available',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                ),
              ),
              SizedBox(height: 16),

              // Image URL
              Text(
                'Image URL',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  nutritionRecord.nutritionInputQuery!.imageUrl ??
                      'No URL available',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 16),

              // Nutrition Items
              Text(
                'Nutrition Details',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: nutritionRecord
                    .nutritionOutput!.response.nutritionData.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[300],
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final nutritionInfo = nutritionRecord
                      .nutritionOutput!.response.nutritionData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nutritionInfo.name,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${nutritionInfo.portion}',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Calories: ${nutritionInfo.calories}',
                              style: TextStyle(color: Colors.black87),
                            ),
                            Text(
                              'Protein: ${nutritionInfo.protein}g',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 16),

              // Performance Metrics
              Text(
                'Performance Metrics',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetricRow(
                      'Input Tokens',
                      '${nutritionRecord.nutritionOutput!.inputTokenCount}',
                    ),
                    _buildMetricRow(
                      'Output Tokens',
                      '${nutritionRecord.nutritionOutput!.outputTokenCount}',
                    ),
                    _buildMetricRow(
                      'Total Tokens',
                      '${nutritionRecord.nutritionOutput!.totalTokenCount}',
                    ),
                    _buildMetricRow(
                      'Estimated Cost',
                      '\$${nutritionRecord.nutritionOutput!.estimatedCost.toStringAsFixed(4)}',
                    ),
                    _buildMetricRow(
                      'Execution Time',
                      '${nutritionRecord.nutritionOutput!.executionTimeSeconds.toStringAsFixed(2)} seconds',
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

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
