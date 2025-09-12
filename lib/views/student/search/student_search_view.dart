import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/student/student_search_controller.dart';
import '../../../widgets/event_card_widget.dart';

class StudentSearchView extends StatefulWidget {
  const StudentSearchView({super.key});

  @override
  State<StudentSearchView> createState() => _StudentSearchViewState();
}

class _StudentSearchViewState extends State<StudentSearchView> {
  final StudentSearchController controller = Get.put(StudentSearchController());
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Debounce function to prevent too many search requests
  void _debounceSearch(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (value.isNotEmpty) {
        controller.searchEvents(value);
      } else {
        controller.clearSearch();
      }
    });
  }

  void _showFilterDialog() {
    // Implement filter dialog for advanced search
    Get.dialog(
      AlertDialog(
        title: const Text('Filter Search'),
        content: const Text('Advanced filter functionality would go here'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              // Apply filters
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Search for Events',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Search by title, description, type, venue, or date',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSearchSuggestion('Conference'),
              _buildSearchSuggestion('Workshop'),
              _buildSearchSuggestion('January'),
              _buildSearchSuggestion('Free'),
              _buildSearchSuggestion('2024'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestion(String suggestion) {
    return GestureDetector(
      onTap: () {
        _searchController.text = suggestion;
        controller.searchEvents(suggestion);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Text(
          suggestion,
          style: TextStyle(color: Colors.blue[700], fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No events found for "${_searchController.text}"',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Try different keywords or check your spelling',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              controller.clearSearch();
            },
            icon: const Icon(Icons.clear),
            label: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        // Search results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Found ${controller.searchResults.length} events',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.searchResults.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EventCardWidget(event: controller.searchResults[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText:
                'Search events by title, description, type, venue, or date...',
            border: InputBorder.none,
            hintStyle: const TextStyle(color: Colors.white70),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      controller.clearSearch();
                    },
                  )
                : null,
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            // Add debounce to prevent too many requests
            _debounceSearch(value);
          },
          onSubmitted: (value) {
            controller.searchEvents(value);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter search',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.hasSearched.value) {
          return _buildEmptyState();
        }

        if (controller.searchResults.isEmpty) {
          return _buildNoResultsState();
        }

        return _buildSearchResults();
      }),
    );
  }
}
