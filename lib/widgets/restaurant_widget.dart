import 'package:flutter/material.dart';
import '../api.dart';
import 'menu_list_widget.dart';

class RestaurantWidget extends StatelessWidget {
  final FilteredRestaurant restaurant;
  final bool scrollable;

  const RestaurantWidget({super.key, required this.restaurant, this.scrollable = true});

  @override
  Widget build(BuildContext context) {
    var content = Column(
      children: [
        Text(
            restaurant.name,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center
        ),
        MenuListWidget(menu: restaurant.menu)
      ],
    );

    return scrollable ? SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 0 , horizontal: 16.0),
      child: content,
    ) : Padding(
      padding: const EdgeInsets.symmetric(vertical: 0 , horizontal: 16.0),
      child: content,
    );
  }
}
