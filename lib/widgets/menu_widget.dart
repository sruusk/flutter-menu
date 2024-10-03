import 'package:flutter/material.dart';
import '../api.dart';

class MenuWidget extends StatelessWidget {
  final SubMenu menu;

  const MenuWidget({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(menu.name, style: Theme.of(context).textTheme.titleMedium),
            ...menu.items.map((item) => ListTile(
              visualDensity: VisualDensity.compact,
              title: Text(item.name, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(item.diets ?? ''),
            )),
          ],
        ),
      )
    );
  }
}
