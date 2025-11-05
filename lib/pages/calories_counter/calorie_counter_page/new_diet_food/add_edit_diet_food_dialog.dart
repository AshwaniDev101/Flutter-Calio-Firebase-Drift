import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/helper.dart';
import '../../../../models/diet_food.dart';
import '../../../../models/food_stats.dart';


class DietFoodDialog {
  static void add(BuildContext context, Function(DietFood) onNewSave) {
    showDialog(context: context, builder: (_) => _DietFoodDialogWidget.save(context: context, onNew: (food){
      onNewSave(food);
      Navigator.of(context).pop();
    }));
  }

  static void edit(BuildContext context, DietFood food, Function(DietFood) onEditSave) {
    showDialog(
        context: context,
        builder: (_) => _DietFoodDialogWidget.edit(context: context, food: food, onEdit: (food){
          onEditSave(food);
          Navigator.of(context).pop();
        }));
  }
}


class _DietFoodDialogWidget extends StatelessWidget {
  final DietFood? food;
  final void Function(DietFood food)? onNew;
  final void Function(DietFood food)? onEdit;

  const _DietFoodDialogWidget.save({required BuildContext context,
    required this.onNew,
  }): food=null ,onEdit=null;

  const _DietFoodDialogWidget.edit({required BuildContext context,
    required this.food,
    required this.onEdit,
  }): onNew=null;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    // Pre-fill values if editing
    String name = food?.name ?? '';
    String calories = food?.foodStats.calories.toString() ?? '';
    String proteins = food?.foodStats.proteins.toString() ?? '';
    String carbohydrates = food?.foodStats.carbohydrates.toString() ?? '';
    String fats = food?.foodStats.fats.toString() ?? '';
    String vitamins = food?.foodStats.vitamins.toString() ?? '';
    String minerals = food?.foodStats.minerals.toString() ?? '';

    InputDecoration buildInputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        floatingLabelStyle: const TextStyle(
          color: Colors.pink,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.grey[100],
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      );
    }

    Widget buildNumberField({
      required String label,
      required String initialValue,
      required Function(String) onSaved,
    }) {
      return Expanded(
        child: TextFormField(
          initialValue: initialValue,
          decoration: buildInputDecoration(label),
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14),
          onSaved: (v) => onSaved(v ?? '0'),
        ),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(14),
      title: Center(
        child: Row(
          children: [
            Icon(Icons.fastfood_rounded,color: Colors.grey[700],),
            const SizedBox(width: 12),
            Text(
              food == null ? 'Add New Diet Food' : 'Edit Diet Food',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: buildInputDecoration('Food Name'),
                style: const TextStyle(fontSize: 14),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
                onSaved: (v) => name = v!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: calories,
                decoration: buildInputDecoration('Calories'),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
                onSaved: (v) => calories = v!.trim(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  buildNumberField(
                      label: 'Proteins', initialValue: proteins, onSaved: (v) => proteins = v),
                  const SizedBox(width: 12),
                  buildNumberField(
                      label: 'Vitamins', initialValue: vitamins, onSaved: (v) => vitamins = v),
                  const SizedBox(width: 12),
                  buildNumberField(
                      label: 'Fats', initialValue: fats, onSaved: (v) => fats = v),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  buildNumberField(
                      label: 'Carbohydrates', initialValue: carbohydrates, onSaved: (v) => carbohydrates = v),
                  const SizedBox(width: 12),
                  buildNumberField(
                      label: 'Minerals', initialValue: minerals, onSaved: (v) => minerals = v),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'CANCEL',
            style: TextStyle(fontSize: 13, color: Colors.pink[300]),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();

              final updatedDietFood = DietFood(
                id: food?.id ?? generateReadableTimestamp(),
                name: name,
                count: 0.0,
                time: Timestamp.fromDate(DateTime.now()),
                foodStats: FoodStats(
                  proteins: double.tryParse(proteins) ?? 0.0,
                  carbohydrates: double.tryParse(carbohydrates) ?? 0.0,
                  fats: double.tryParse(fats) ?? 0.0,
                  vitamins: double.tryParse(vitamins) ?? 0.0,
                  minerals: double.tryParse(minerals) ?? 0.0,
                  calories: double.tryParse(calories) ?? 0.0,
                ),
              );


              if(food == null) {
                onNew!(updatedDietFood);
              } else {
                onEdit!(updatedDietFood);
              }


            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink[300],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
          child: Text(
            food == null ? 'ADD' : 'SAVE',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
