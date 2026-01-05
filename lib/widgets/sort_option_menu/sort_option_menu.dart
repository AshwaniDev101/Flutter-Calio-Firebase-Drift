
import 'package:calio/pages/calorie_counter/view_model.dart';
import 'package:flutter/material.dart';

class SortOptionMenu extends StatelessWidget {

  final CalorieCounterViewModel viewModel;
  const SortOptionMenu({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.sort),
      itemBuilder: (context){
      return [
        PopupMenuItem(value: SortType.aToB,child: Text('A-B'),),
        PopupMenuItem(value: SortType.bToA,child: Text('B-A'),),
        PopupMenuItem(value: SortType.calHighToLow,child: Text('Decrement'),),
        PopupMenuItem(value: SortType.calLowToLHigh,child: Text('Increment'),),
        PopupMenuItem(value: SortType.consumed,child: Text('consumed'),)
      ];
    },

    onSelected: (sortType)
    {
      viewModel.updateSortType = sortType;
    },
    );
  }
}
