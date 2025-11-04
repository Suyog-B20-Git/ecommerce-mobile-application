import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../controller/search_controller.dart' as sc;
import '../../routes/routes.dart';
import '../../utils/storage_config.dart';
import '../../utils/app_enums.dart';
import '../../models/search_suggestion.dart';
import '../../utils/text_styles.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  late sc.SearchController searchController;
  final TextEditingController _textController = TextEditingController();
  final RxString _query = ''.obs;

  @override
  void initState() {
    super.initState();
    searchController = Get.put(sc.SearchController());
    searchController.setupDebouncedSuggestions(_query);
  }

  void _submit(String query) async {
    final String q = query.trim();
    if (q.isEmpty) return;
    await searchController.addToRecent(q);
    Get.toNamed(
      Routes.PRODUCT_LIST_SCREEN,
      arguments: {'title': q, 'searchTerm': q},
    );
  }

  void _handleSuggestionTap(SearchSuggestion s) async {
    // Save meaningful term for history
    await searchController.addToRecent(s.title);
    if (s.type == 'category' && s.categoryId.isNotEmpty) {
      Get.toNamed(
        Routes.PRODUCT_LIST_SCREEN,
        arguments: {
          'title': s.title,
          'categoryId': s.categoryId,
          'fromGlobalSearch': true,
        },
      );
      return;
    }
    if (s.type == 'subcategory' && s.id.isNotEmpty) {
      Get.toNamed(
        Routes.PRODUCT_LIST_SCREEN,
        arguments: {
          'title': s.title,
          'subcategoryId': s.id,
          'fromGlobalSearch': true,
        },
      );
      return;
    }
    if (s.type == 'product') {
      // Open product list by subcategory when available, else category, else keyword search
      if (s.subcategoryId.isNotEmpty) {
        Get.toNamed(
          Routes.PRODUCT_LIST_SCREEN,
          arguments: {
            'title': s.title,
            'subcategoryId': s.subcategoryId,
            'fromGlobalSearch': true,
          },
        );
        return;
      }
      if (s.categoryId.isNotEmpty) {
        Get.toNamed(
          Routes.PRODUCT_LIST_SCREEN,
          arguments: {
            'title': s.title,
            'categoryId': s.categoryId,
            'fromGlobalSearch': true,
          },
        );
        return;
      }
      // fallback to keyword search list
      _submit(s.title);
      return;
    }
    // default to keyword search
    _submit(s.title);
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      child: Text(
        title,
        style: TextHelper.size15(
          context,
        ).copyWith(fontWeight: FontWeight.w600, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0EA5E9).withAlpha((0.3 * 255).toInt()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: const Color(0xFF0EA5E9), width: 2),
            ),
            child: Row(
              children: [
                SizedBox(width: 3.w),
                const Icon(Icons.search, color: Color(0xFF0EA5E9)),
                SizedBox(width: 3.w),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search for products, category and more',
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      isDense: true,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    style: TextHelper.size15(
                      context,
                    ).copyWith(color: Colors.black),
                    textInputAction: TextInputAction.search,
                    onSubmitted: _submit,
                    onChanged: (value) {
                      _query.value = value;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black54),
                  onPressed: () {
                    _textController.clear();
                    _query.value = '';
                    searchController.suggestions.clear();
                    FocusScope.of(context).unfocus();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        final hasTyped = _query.value.trim().isNotEmpty;
        return ListView(
          children: [
            if (hasTyped) _sectionTitle('Suggestions'),
            if (hasTyped)
              Padding(
                padding: EdgeInsets.only(bottom: 2.w),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: Column(
                    children: [
                      if (searchController.loadingSuggestions.value)
                        const LinearProgressIndicator(minHeight: 2),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: searchController.suggestions.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                        itemBuilder: (context, index) {
                          final s = searchController.suggestions[index];
                          final title = s.title;
                          final subtitle = s.subtitle;
                          // Different icons for different types
                          IconData iconData;
                          if (s.type == 'category') {
                            iconData = Icons.category;
                          } else if (s.type == 'subcategory') {
                            iconData = Icons.category;
                          } else {
                            iconData = Icons.search;
                          }
                          return ListTile(
                            tileColor: Colors.white,
                            leading: Icon(
                              iconData,
                              color: const Color(0xFF0EA5E9),
                            ),
                            title: Text(
                              title,
                              style: TextHelper.size15(
                                context,
                              ).copyWith(color: Colors.black),
                            ),
                            subtitle: subtitle.isNotEmpty
                                ? Text(
                                    subtitle,
                                    style: TextHelper.size13(
                                      context,
                                    ).copyWith(color: Colors.grey),
                                  )
                                : null,
                            onTap: () => _handleSuggestionTap(s),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            if (!hasTyped) _sectionTitle('Recommended'),
            if (!hasTyped)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: Wrap(
                    spacing: 2.w,
                    runSpacing: 2.w,
                    children: searchController.recommendations
                        .map(
                          (s) => ActionChip(
                            label: Text(
                              s.title,
                              style: TextHelper.size13(
                                context,
                              ).copyWith(color: const Color(0xFF0EA5E9)),
                            ),
                            onPressed: () => _handleSuggestionTap(s),
                            backgroundColor: const Color(0xFFEFF8FF),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),

            // Recent header row with Clear all
            if (!hasTyped)
              Padding(
                padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 2.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent searches',
                      style: TextHelper.size15(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    TextButton.icon(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                      onPressed: () => searchController.clearRecent(),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.black,
                      ),
                      label: Text(
                        'Clear all',
                        style: TextHelper.size13(
                          context,
                        ).copyWith(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            if (!hasTyped && searchController.recentSearches.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'No recent searches',
                  style: TextHelper.size13(
                    context,
                  ).copyWith(color: Colors.grey),
                ),
              )
            else if (!hasTyped)
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
                child: Column(
                  children: [
                    ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: searchController.recentSearches.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: Colors.grey,
                        thickness: 0.5,
                      ),
                      itemBuilder: (context, index) {
                        final term = searchController.recentSearches[index];
                        return ListTile(
                          tileColor: Colors.white,
                          leading: const Icon(
                            Icons.history,
                            color: Colors.black54,
                          ),
                          title: Text(
                            term,
                            style: TextHelper.size15(
                              context,
                            ).copyWith(color: Colors.black),
                          ),
                          onTap: () => _submit(term),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () async {
                              final updated = List<String>.from(
                                searchController.recentSearches,
                              );
                              updated.removeAt(index);
                              searchController.recentSearches.assignAll(
                                updated,
                              );
                              await LocalStorage.storeValue(
                                StorageKey.recentSearches,
                                updated,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }
}
