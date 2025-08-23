import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class RecycleScreen extends StatefulWidget {
  const RecycleScreen({super.key});

  @override
  State<RecycleScreen> createState() => _RecycleScreenState();
}

class _RecycleScreenState extends State<RecycleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentStep = 0;

  final List<WasteCategory> wasteCategories = [
    WasteCategory(
      name: 'Biodegradable',
      color: const Color(0xFF4CAF50),
      icon: Icons.eco,
      description: 'Organic waste that naturally decomposes',
      steps: [
        WasteStep(
          title: 'Identify Biodegradable Items',
          description:
              'Look for organic materials that can decompose naturally',
          examples: [
            'Food scraps',
            'Fruit peels',
            'Vegetable waste',
            'Garden trimmings',
            'Paper',
            'Cardboard',
          ],
          icon: Icons.visibility,
        ),
        WasteStep(
          title: 'Clean Food Containers',
          description:
              'Remove any food residue from containers before disposal',
          examples: [
            'Rinse containers',
            'Remove labels if possible',
            'Scrape off remaining food',
          ],
          icon: Icons.cleaning_services,
        ),
        WasteStep(
          title: 'Separate from Other Waste',
          description: 'Place biodegradable items in designated green bins',
          examples: [
            'Use green or brown bins',
            'Keep dry items separate from wet',
            'Layer materials properly',
          ],
          icon: Icons.recycling,
        ),
        WasteStep(
          title: 'Proper Storage',
          description: 'Store biodegradable waste correctly to prevent odors',
          examples: [
            'Use lined bins',
            'Empty regularly',
            'Keep in cool, dry place',
          ],
          icon: Icons.storage,
        ),
      ],
    ),
    WasteCategory(
      name: 'Non-Biodegradable',
      color: const Color(0xFFFF7043),
      icon: Icons.block,
      description: 'Materials that do not decompose naturally',
      steps: [
        WasteStep(
          title: 'Identify Non-Biodegradable Items',
          description: 'Recognize materials that cannot decompose naturally',
          examples: [
            'Plastic bags',
            'Styrofoam',
            'Rubber items',
            'Metal cans',
            'Glass bottles',
          ],
          icon: Icons.search,
        ),
        WasteStep(
          title: 'Clean and Prepare',
          description: 'Clean items before disposal to prevent contamination',
          examples: [
            'Rinse containers',
            'Remove caps and lids',
            'Dry thoroughly',
          ],
          icon: Icons.wash,
        ),
        WasteStep(
          title: 'Sort by Material Type',
          description: 'Group similar materials together for proper processing',
          examples: [
            'Separate plastics by type',
            'Group metal items',
            'Keep glass separate',
          ],
          icon: Icons.sort,
        ),
        WasteStep(
          title: 'Use Designated Bins',
          description:
              'Place items in appropriate non-biodegradable waste bins',
          examples: [
            'Use red or black bins',
            'Follow local guidelines',
            'Avoid overpacking',
          ],
          icon: Icons.delete,
        ),
      ],
    ),
    WasteCategory(
      name: 'Recyclable',
      color: const Color(0xFF2196F3),
      icon: Icons.autorenew,
      description: 'Materials that can be processed into new products',
      steps: [
        WasteStep(
          title: 'Check Recycling Symbols',
          description: 'Look for recycling symbols and numbers on items',
          examples: [
            'Plastic numbers 1-7',
            'Recycling arrows symbol',
            'Material identification codes',
          ],
          icon: Icons.numbers,
        ),
        WasteStep(
          title: 'Clean Thoroughly',
          description: 'Clean all recyclable items to remove contaminants',
          examples: [
            'Remove food residue',
            'Rinse with water',
            'Remove tape and stickers',
          ],
          icon: Icons.water_drop,
        ),
        WasteStep(
          title: 'Separate by Category',
          description: 'Sort recyclables into proper categories',
          examples: [
            'Paper products',
            'Plastic containers',
            'Metal cans',
            'Glass bottles',
          ],
          icon: Icons.category,
        ),
        WasteStep(
          title: 'Prepare for Collection',
          description: 'Package recyclables correctly for pickup',
          examples: [
            'Use recycling bins',
            'Flatten cardboard',
            'Bundle paper materials',
          ],
          icon: Icons.local_shipping,
        ),
      ],
    ),
    WasteCategory(
      name: 'Hazardous',
      color: const Color(0xFFE91E63),
      icon: Icons.warning,
      description: 'Dangerous materials requiring special handling',
      steps: [
        WasteStep(
          title: 'Identify Hazardous Materials',
          description:
              'Recognize items that pose health or environmental risks',
          examples: [
            'Batteries',
            'Paint cans',
            'Chemicals',
            'Light bulbs',
            'Electronics',
          ],
          icon: Icons.dangerous,
        ),
        WasteStep(
          title: 'Handle with Care',
          description: 'Use proper safety precautions when handling',
          examples: [
            'Wear gloves',
            'Avoid direct contact',
            'Work in ventilated area',
          ],
          icon: Icons.health_and_safety,
        ),
        WasteStep(
          title: 'Keep Original Containers',
          description: 'Store hazardous items in their original packaging',
          examples: [
            'Do not mix chemicals',
            'Keep labels intact',
            'Secure containers',
          ],
          icon: Icons.inventory_2,
        ),
        WasteStep(
          title: 'Find Special Collection Points',
          description: 'Locate authorized disposal facilities',
          examples: [
            'Contact local authorities',
            'Visit collection centers',
            'Schedule pickup',
          ],
          icon: Icons.location_on,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: wasteCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: wasteCategories
                    .map((category) => _buildCategoryView(category))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowDark.withOpacity(0.15),
                      offset: const Offset(4, 4),
                      blurRadius: 8,
                    ),
                    const BoxShadow(
                      color: AppColors.shadowLight,
                      offset: Offset(-4, -4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.recycling,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waste Segregation Guide',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Learn proper waste separation techniques',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.pureWhite,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primaryGreen,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primaryGreen,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: wasteCategories
            .map(
              (category) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(category.icon, size: 18),
                    const SizedBox(width: 8),
                    Text(category.name),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCategoryView(WasteCategory category) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(category),
          const SizedBox(height: 20),
          Expanded(child: _buildStepsList(category)),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(WasteCategory category) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withOpacity(0.15),
            offset: const Offset(6, 6),
            blurRadius: 12,
          ),
          const BoxShadow(
            color: AppColors.shadowLight,
            offset: Offset(-6, -6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(category.icon, color: category.color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: category.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList(WasteCategory category) {
    return ListView.builder(
      itemCount: category.steps.length,
      itemBuilder: (context, index) {
        return _buildStepCard(category.steps[index], index + 1, category.color);
      },
    );
  }

  Widget _buildStepCard(WasteStep step, int stepNumber, Color categoryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withOpacity(0.1),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
          const BoxShadow(
            color: AppColors.shadowLight,
            offset: Offset(-4, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    stepNumber.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(step.icon, color: categoryColor, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            step.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: step.examples
                .map((example) => _buildExampleChip(example, categoryColor))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleChip(String example, Color categoryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: categoryColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        example,
        style: TextStyle(
          fontSize: 12,
          color: categoryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class WasteCategory {
  final String name;
  final Color color;
  final IconData icon;
  final String description;
  final List<WasteStep> steps;

  WasteCategory({
    required this.name,
    required this.color,
    required this.icon,
    required this.description,
    required this.steps,
  });
}

class WasteStep {
  final String title;
  final String description;
  final List<String> examples;
  final IconData icon;

  WasteStep({
    required this.title,
    required this.description,
    required this.examples,
    required this.icon,
  });
}
