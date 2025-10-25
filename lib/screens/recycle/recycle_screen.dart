import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../l10n/app_localizations.dart';

class RecycleScreen extends StatefulWidget {
  const RecycleScreen({super.key});

  @override
  State<RecycleScreen> createState() => _RecycleScreenState();
}

class _RecycleScreenState extends State<RecycleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<WasteCategory> wasteCategories;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildLocalizedCategories();
  }

  void _buildLocalizedCategories() {
    final l10n = AppLocalizations.of(context)!;
    
    wasteCategories = [
      WasteCategory(
        name: l10n.biodegradable,
        color: const Color(0xFF4CAF50),
        icon: Icons.eco,
        description: l10n.biodegradableDesc,
        steps: [
          WasteStep(
            title: l10n.identifyBiodegradableItems,
            description: l10n.identifyBiodegradableItemsDesc,
            examples: [
              l10n.exampleFoodScraps,
              l10n.exampleFruitPeels,
              l10n.exampleVegetableWaste,
              l10n.exampleGardenTrimmings,
              l10n.examplePaper,
              l10n.exampleCardboard,
            ],
            icon: Icons.visibility,
          ),
          WasteStep(
            title: l10n.cleanFoodContainers,
            description: l10n.cleanFoodContainersDesc,
            examples: [
              l10n.exampleRinseContainers,
              l10n.exampleRemoveLabels,
              l10n.exampleScrapeFood,
            ],
            icon: Icons.cleaning_services,
          ),
          WasteStep(
            title: l10n.separateFromOtherWaste,
            description: l10n.separateFromOtherWasteDesc,
            examples: [
              l10n.exampleGreenBins,
              l10n.exampleKeepDrySeparate,
              l10n.exampleLayerMaterials,
            ],
            icon: Icons.recycling,
          ),
          WasteStep(
            title: l10n.properStorage,
            description: l10n.properStorageDesc,
            examples: [
              l10n.exampleLinedBins,
              l10n.exampleEmptyRegularly,
              l10n.exampleCoolPlace,
            ],
            icon: Icons.storage,
          ),
        ],
      ),
      WasteCategory(
        name: l10n.nonBiodegradable,
        color: const Color(0xFFFF7043),
        icon: Icons.block,
        description: l10n.nonBiodegradableDesc,
        steps: [
          WasteStep(
            title: l10n.identifyNonBiodegradableItems,
            description: l10n.identifyNonBiodegradableItemsDesc,
            examples: [
              l10n.examplePlasticBags,
              l10n.exampleStyrofoam,
              l10n.exampleRubberItems,
              l10n.exampleMetalCans,
              l10n.exampleGlassBottles,
            ],
            icon: Icons.search,
          ),
          WasteStep(
            title: l10n.cleanAndPrepare,
            description: l10n.cleanAndPrepareDesc,
            examples: [
              l10n.exampleRinseContainers,
              l10n.exampleRemoveCaps,
              l10n.exampleDryThoroughly,
            ],
            icon: Icons.wash,
          ),
          WasteStep(
            title: l10n.sortByMaterialType,
            description: l10n.sortByMaterialTypeDesc,
            examples: [
              l10n.exampleSeparatePlastics,
              l10n.exampleGroupMetal,
              l10n.exampleKeepGlassSeparate,
            ],
            icon: Icons.sort,
          ),
          WasteStep(
            title: l10n.useDesignatedBins,
            description: l10n.useDesignatedBinsDesc,
            examples: [
              l10n.exampleRedBins,
              l10n.exampleFollowGuidelines,
              l10n.exampleAvoidOverpacking,
            ],
            icon: Icons.delete,
          ),
        ],
      ),
      WasteCategory(
        name: l10n.recyclable,
        color: const Color(0xFF2196F3),
        icon: Icons.autorenew,
        description: l10n.recyclableDesc,
        steps: [
          WasteStep(
            title: l10n.checkRecyclingSymbols,
            description: l10n.checkRecyclingSymbolsDesc,
            examples: [
              l10n.examplePlasticNumbers,
              l10n.exampleRecyclingSymbol,
              l10n.exampleMaterialCodes,
            ],
            icon: Icons.numbers,
          ),
          WasteStep(
            title: l10n.cleanThoroughly,
            description: l10n.cleanThoroughlyDesc,
            examples: [
              l10n.exampleRemoveFoodResidue,
              l10n.exampleRinseWater,
              l10n.exampleRemoveTape,
            ],
            icon: Icons.water_drop,
          ),
          WasteStep(
            title: l10n.separateByCategory,
            description: l10n.separateByCategoryDesc,
            examples: [
              l10n.examplePaperProducts,
              l10n.examplePlasticContainers,
              l10n.exampleMetalCans,
              l10n.exampleGlassBottles,
            ],
            icon: Icons.category,
          ),
          WasteStep(
            title: l10n.prepareForCollection,
            description: l10n.prepareForCollectionDesc,
            examples: [
              l10n.exampleRecyclingBins,
              l10n.exampleFlattenCardboard,
              l10n.exampleBundlePaper,
            ],
            icon: Icons.local_shipping,
          ),
        ],
      ),
      WasteCategory(
        name: l10n.hazardous,
        color: const Color(0xFFE91E63),
        icon: Icons.warning,
        description: l10n.hazardousDesc,
        steps: [
          WasteStep(
            title: l10n.identifyHazardousMaterials,
            description: l10n.identifyHazardousMaterialsDesc,
            examples: [
              l10n.exampleBatteries,
              l10n.examplePaintCans,
              l10n.exampleChemicals,
              l10n.exampleLightBulbs,
              l10n.exampleElectronics,
            ],
            icon: Icons.dangerous,
          ),
          WasteStep(
            title: l10n.handleWithCare,
            description: l10n.handleWithCareDesc,
            examples: [
              l10n.exampleWearGloves,
              l10n.exampleAvoidContact,
              l10n.exampleVentilatedArea,
            ],
            icon: Icons.health_and_safety,
          ),
          WasteStep(
            title: l10n.keepOriginalContainers,
            description: l10n.keepOriginalContainersDesc,
            examples: [
              l10n.exampleDontMixChemicals,
              l10n.exampleKeepLabels,
              l10n.exampleSecureContainers,
            ],
            icon: Icons.inventory_2,
          ),
          WasteStep(
            title: l10n.findSpecialCollectionPoints,
            description: l10n.findSpecialCollectionPointsDesc,
            examples: [
              l10n.exampleContactAuthorities,
              l10n.exampleVisitCenters,
              l10n.exampleSchedulePickup,
            ],
            icon: Icons.location_on,
          ),
        ],
      ),
    ];
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
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.1),
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
                      color: AppColors.shadowDark.withValues(alpha: 0.15),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.wasteSegregationGuide,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.learnProperWasteSeparation,
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
            color: AppColors.shadowDark.withValues(alpha: 0.15),
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
              color: category.color.withValues(alpha: 0.1),
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
            color: AppColors.shadowDark.withValues(alpha: 0.1),
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
        color: categoryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: categoryColor.withValues(alpha: 0.3), width: 1),
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
