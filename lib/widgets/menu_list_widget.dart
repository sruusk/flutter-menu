// lib/widgets/menu_list_widget.dart
import 'package:flutter/material.dart';
import 'package:lunch_menu/localisation.dart';
import './menu_widget.dart';
import '../api.dart';

class MenuListWidget extends StatelessWidget {
  final Menu menu;

  const MenuListWidget({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    String currentLanguage = Localizations.localeOf(context).languageCode;
    return Column(
      children: [
        Text(AppLocalizations.of(context).translate('weekdays.${MenuApi.getDayOfWeek(menu.date.weekday)}')),
        for (var item in menu[currentLanguage]) MenuWidget(menu: item),
        const SizedBox(height: 16.0),
      ],
    );
  }
}