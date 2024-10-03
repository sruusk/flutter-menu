import 'package:flutter/material.dart';
import '../api.dart';
import 'menu_list_widget.dart';

class RestaurantWidget extends StatelessWidget {
  final FilteredRestaurant restaurant;

  const RestaurantWidget({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 0 , horizontal: 16.0),
      child: Column(
        children: [
          Text(
              restaurant.name,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center
          ),
          MenuListWidget(menu: restaurant.menu)
        ],
      ),
    );
  }
}