import 'package:flutter/material.dart';
import '../../../../models/diet_food.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/new_button/new_button_widget.dart';
import '../../../../widgets/sort_option_menu/sort_option_menu.dart';
import '../../add_new/add_edit_dialog.dart';
import '../../view_model.dart';

/// A pinned search bar sliver that stays at the top of the food list.
/// Includes a search field, an "Add New" button, and a sort menu.
class MySearchBarSliver extends StatefulWidget {
  final CalorieCounterViewModel viewModel;

  const MySearchBarSliver({required this.viewModel, super.key});

  @override
  State<MySearchBarSliver> createState() => _SearchBarState();
}

class _SearchBarState extends State<MySearchBarSliver> with WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();
  double _prevBottomInset = 0;

  @override
  void initState() {
    super.initState();
    // Observe metrics changes to detect when the keyboard is closed
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
    // Automatically unfocus the search bar when the keyboard is dismissed manually
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    if (_prevBottomInset > 0 && bottomInset == 0 && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
    _prevBottomInset = bottomInset;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverPersistentHeader(
      pinned: true,
      delegate: _SearchBarDelegate(
        height: 50,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: Container(

            // clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor, // Background color prevents content from bleeding through when pinned
              // color: Colors.red,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16),bottomRight: Radius.circular(16)), // rounded corners
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black12,
              //     blurRadius: 8,
              //     offset: Offset(0, 4), // subtle shadow
              //   ),
              // ],
            ),

            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Row(
              children: [
                // --- Search Input Field ---
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: TextField(
                      focusNode: _focusNode,
                      onChanged: (value) => widget.viewModel.updateSearchQuery = value,
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

                // --- Action Buttons ---
                Row(
                  children: [
                    // Add New Food Button

                    // NewButtonWidget(
                    //   label: 'New',
                    //   onPressed: (){
                    //     DietFoodDialog.add(context, (DietFood food) => widget.viewModel.addFood(food));
                    //   },
                    //
                    // ),
                    InkWell(
                      onTap: () {
                        DietFoodDialog.add(context, (DietFood food) => widget.viewModel.addFood(food));
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: AppColors.appbarContent, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'New',
                              style: TextStyle(fontSize: 12, color: AppColors.appbarContent, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // const SizedBox(width: 10),

                    // Sort Options Menu
                    SortOptionMenu(viewModel: widget.viewModel),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Delegate that handles the layout and pinning behavior for the search bar.
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SearchBarDelegate({required this.child, required this.height});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
