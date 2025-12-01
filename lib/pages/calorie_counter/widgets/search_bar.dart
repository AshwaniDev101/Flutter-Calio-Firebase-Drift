// Search bar widget (stateful) manages keyboard insets and focus
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/diet_food.dart';
import '../../../theme/app_colors.dart';
import '../add_new/add_edit_dialog.dart';
import '../view_model.dart';

class SearchBar extends StatefulWidget {
  const SearchBar();

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> with WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();
  double _prevBottomInset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    if (_prevBottomInset > 0 && bottomInset == 0 && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
    _prevBottomInset = bottomInset;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<CalorieCounterViewModel>();

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 38, // keep it thin
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 3, offset: const Offset(0, 1)),
              ],
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: TextField(
              focusNode: _focusNode,
              onChanged: (value) => vm.updateSearchQuery = value,
              style: const TextStyle(fontSize: 12, height: 1.2),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Search foods...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                isDense: true,
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600], size: 16),
                prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(width: 6),

        InkWell(
          onTap: () => DietFoodDialog.add(context, (DietFood food) => context.read<CalorieCounterViewModel>().addFood(food)),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 38, // same as search bar
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 3, offset: const Offset(0, 1)),
              ],
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: AppColors.appbarContent, size: 16),
                const SizedBox(width: 6),
                Text('New', style: TextStyle(fontSize: 12, color: AppColors.appbarContent, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),
      ],
    );
  }
}