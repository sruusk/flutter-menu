import 'package:flutter/material.dart';
import 'package:lunch_menu/localisation.dart';
import 'package:tuple/tuple.dart';
import '../api.dart';
import '../preferences.dart';
import '../provider.dart';
import '../update.dart';
import 'settings_widgets.dart';

class DateBottomSheet extends StatefulWidget {
  final Future<List<Tuple2<DateTime, String>>> availableDates;
  final Future<List<Campus>> campuses;
  final Function(DateTime) setDate;
  final MenuApi api;
  final DateTime date;

  const DateBottomSheet({
    required this.availableDates,
    required this.campuses,
    required this.setDate,
    required this.api,
    required this.date,
    super.key,
  });

  @override
  State<DateBottomSheet> createState() => _DateBottomSheetState();
}

class _DateBottomSheetState extends State<DateBottomSheet> with SingleTickerProviderStateMixin {
  bool updateAvailable = false;
  late Updater updater;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    updater = Updater();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferencesNotifier = Provider.of<PreferencesNotifier>(context);

    return SingleChildScrollView(
      child: FutureBuilder<List<Tuple2<DateTime, String>>>(
        future: widget.availableDates,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
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
                          style: Theme.of(context).textTheme.headlineSmall,
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
                              widget.setDate(dateOption.item1);
                              Navigator.pop(context);
                            },
                          ),
                      ],
                      buttonText: AppLocalizations.of(context).translate('weekdays.${MenuApi.getDayOfWeek(widget.date.weekday)}'),
                      onPressed: () {},
                    ),
                  ),
                  FutureBuilder(
                    future: widget.campuses,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SettingsCard(
                          title: "${AppLocalizations.of(context).translate('settings.selectCampus')}: ",
                          child: MenuAnchorWidget(
                            menuChildren: [
                              for (var campus in snapshot.data!)
                                MenuItemButton(
                                  child: Text(campus.toString()),
                                  onPressed: () {
                                    preferencesNotifier.setPreference('campus', campus.toString());
                                    Navigator.pop(context);
                                  },
                                ),
                            ],
                            buttonText: preferencesNotifier.value.preferences['campus'] ?? '',
                            onPressed: () {},
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
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
                  FutureBuilder(
                    future: updater.currentVersion,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SettingsCard(
                          title: "${AppLocalizations.of(context).translate('settings.version')}: ",
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.surfaceBright),
                              shadowColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.shadow),
                              elevation: WidgetStateProperty.all<double>(2),
                            ),
                            onPressed: () async {
                              _controller.repeat();
                              bool isUpdateAvailable = await updater.isUpdateAvailable(forceCheck: true);
                              setState(() {
                                updateAvailable = isUpdateAvailable;
                              });
                              _controller.stop();
                              _controller.forward();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(updateAvailable ? AppLocalizations.of(context).translate('update.update') : snapshot.data.toString(), style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(width: 8),
                                RotationTransition(
                                  turns: _animation,
                                  child: updateAvailable ? const Icon(Icons.download) : const Icon(Icons.refresh),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

Future<void> showDateBottomSheet(
  BuildContext context,
  Future<List<Tuple2<DateTime, String>>> availableDates,
  Future<List<Campus>> campuses,
  Function(DateTime) setDate,
  MenuApi api,
  DateTime date,
) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    enableDrag: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (BuildContext builder) {
      return DateBottomSheet(
        availableDates: availableDates,
        campuses: campuses,
        setDate: setDate,
        api: api,
        date: date,
      );
    },
  );
}
