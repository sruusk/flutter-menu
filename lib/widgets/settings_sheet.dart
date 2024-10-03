import 'package:flutter/material.dart';
import 'package:lunch_menu/localisation.dart';
import 'package:tuple/tuple.dart';
import '../api.dart';
import '../preferences.dart';
import '../provider.dart';
import 'settings_widgets.dart';

Future<void> showDateBottomSheet(BuildContext context, Future<List<Tuple2<DateTime, String>>> availableDates, Function(DateTime) setDate, MenuApi api, DateTime date) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    enableDrag: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (BuildContext builder) {
      final preferencesNotifier = Provider.of<PreferencesNotifier>(context);

      return FutureBuilder<List<Tuple2<DateTime, String>>>(
        future: availableDates,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              height: MediaQuery.of(context).size.height / 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                            AppLocalizations.of(context).translate('settings.settings'),
                            style: Theme.of(context).textTheme.headlineSmall
                        ),
                      ],
                    ),
                  ),
                  SettingsCard(
                    title: "${AppLocalizations.of(context).translate('settings.selectDay')}: ",
                    child: MenuAnchorWidget(
                      menuChildren: [
                        for (var dateOption in snapshot.data!)
                          MenuItemButton(
                            child: Text(AppLocalizations.of(context).translate('weekdays.${MenuApi.getDayOfWeek(dateOption.item1.weekday)}')),
                            onPressed: () {
                              setDate(dateOption.item1);
                              Navigator.pop(context);
                            },
                          ),
                      ],
                      buttonText: AppLocalizations.of(context).translate('weekdays.${MenuApi.getDayOfWeek(date.weekday)}'),
                      onPressed: () {},
                    ),
                  ),
                  SettingsCard(
                    title: "${AppLocalizations.of(context).translate('settings.selectLang')}: ",
                    child: MenuAnchorWidget(
                      menuChildren: [
                        MenuItemButton(
                          child: const Text('English'),
                          onPressed: () {
                            preferencesNotifier.setPreference('language_code', 'en');
                            Navigator.pop(context);
                          },
                        ),
                        MenuItemButton(
                          child: const Text('Suomi'),
                          onPressed: () {
                            preferencesNotifier.setPreference('language_code', 'fi');
                            Navigator.pop(context);
                          },
                        ),
                      ],
                      buttonText: AppLocalizations.of(context).translate('settings.${AppLocalizations.of(context).locale.languageCode}'),
                      onPressed: () {},
                    ),
                  ),
                ]
              )
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    },
  );
}
