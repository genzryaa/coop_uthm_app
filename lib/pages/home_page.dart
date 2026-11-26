import 'package:flutter/material.dart';
import '../data/coop_data.dart';
import '../widgets/product_card.dart';

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({super.key});

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Snacks',
    'Beverages',
    'Stationery',
    'Essentials',
  ];

  void _openCatalogSearch() {
    showSearch(
      context: context,
      delegate: _CoopProductSearchDelegate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: coopState,
      builder: (context, _) {
        final products = _selectedCategory == 'All'
            ? coopState.products
            : coopState.products
                .where((p) => p.category == _selectedCategory)
                .toList();

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Image.asset(
                    'assets/images/coop_uthm_logo.png',
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  coopState.tr('retail_store'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: coopState.tr('search_hint'),
                icon: const Icon(Icons.search),
                onPressed: _openCatalogSearch,
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              SizedBox(
                height: 54,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final cat = _categories[idx];
                    final isSelected = cat == _selectedCategory;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                    );
                  },
                ),
              ),
              Expanded(
                child: products.isEmpty
                    ? const Center(child: Text('Loading COOP UTHM products...'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.74,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, idx) =>
                            ProductCard(product: products[idx]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CoopProductSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => coopState.tr('search_hint');

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        coopState.addSearchHistory(query);
      });
    }
    return _buildMatchingGrid();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return ListenableBuilder(
        listenable: coopState,
        builder: (context, _) {
          if (coopState.recentSearches.isEmpty) {
            return const Center(
              child: Text('Type a product name or category to search'),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      coopState.tr('recent_searches'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: coopState.clearSearchHistory,
                      child: Text(coopState.tr('clear')),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: coopState.recentSearches.map((term) {
                    return InputChip(
                      avatar: const Icon(Icons.history, size: 18),
                      label: Text(term),
                      onPressed: () {
                        query = term;
                        showResults(context);
                      },
                      onDeleted: () => coopState.removeSearchHistoryItem(term),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      );
    }
    return _buildMatchingGrid();
  }

  Widget _buildMatchingGrid() {
    final q = query.trim().toLowerCase();
    final matches = coopState.products.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();

    if (matches.isEmpty) {
      return Center(child: Text('No products found for "$query"'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.74,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: matches.length,
      itemBuilder: (context, idx) => ProductCard(product: matches[idx]),
    );
  }
}