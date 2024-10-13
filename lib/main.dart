import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lunch_menu/widgets/delayed_widget.dart';
import 'provider.dart';
import 'package:tuple/tuple.dart';
import 'api.dart';
import 'widgets/settings_sheet.dart';
import 'localisation.dart';
import 'preferences.dart';
import 'widgets/update_widget.dart';
import 'widgets/narrow_restaurant_list.dart';
import 'widgets/wide_restaurant_list.dart';
import 'widgets/error_display.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure the binding is initialized
  runApp(
    Provider<PreferencesNotifier>(
      notifier: PreferencesNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final preferencesNotifier = Provider.of<PreferencesNotifier>(context);

    return MaterialApp(
      title: 'Lunch menus',
      locale: preferencesNotifier.value.preferences['language_code'] != null
          ? Locale(preferencesNotifier.value.preferences['language_code']!)
          : null,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fi', ''), // Finnish, no country code
        Locale('en', ''), // English, no country code
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'Lunch menus'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<FilteredRestaurant>> futureRestaurants;
  late Future<List<Campus>> campuses;
  late Future<List<Tuple2<DateTime, String>>> availableDates;
  DateTime date = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final MenuApi api = MenuApi();


  @override
  void initState() {
    super.initState();
    futureRestaurants = api.menu;
    availableDates = api.getAvailableDates();
    campuses = api.getCampuses();
    availableDates.then(((dates) {
      if (dates.isNotEmpty) {
        _setDate(dates.first.item1);
      }
    }));
  }

  _setDate(DateTime newDate) {
    setState(() {
      date = newDate;
      api.selectedDate = date;
      futureRestaurants = api.menu;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    final preferencesNotifier = Provider.of<PreferencesNotifier>(context);
    return Scaffold(
      body: Column(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        children: [
          const UpdateWidget(),
          Expanded(
            child: FutureBuilder<List<FilteredRestaurant>>(
              future: futureRestaurants,
              builder: (context, snapshot) {
                if(preferencesNotifier.value.preferences['campus'].runtimeType != String || preferencesNotifier.value.preferences['campus'] == '') {
                  if(snapshot.data != null && snapshot.data!.isNotEmpty) {
                    preferencesNotifier.setPreference(
                        'campus', snapshot.data!.first.campus.toString());
                  }
                }
                List<FilteredRestaurant>? data = snapshot.data?.where((element) => element.campus.toString() == preferencesNotifier.value.preferences['campus']).toList();
                if (snapshot.hasData && data != null && data.isNotEmpty) {
                  return LayoutBuilder(builder: (context, constraints) {
                    if(constraints.maxWidth > 600) {
                      return WideRestaurantView(data: data);
                    } else {
                      return NarrowRestaurantList(data: data);
                    }
                  });
                } else if (snapshot.hasError) {
                  return ErrorDisplay(
                    error: snapshot.error!,
                    onRetry: () {
                      setState(() {
                        futureRestaurants = api.menu;
                      });
                    },
                  );
                } else if(data != null && data.isEmpty && snapshot.connectionState == ConnectionState.done) {
                  return DelayedWidget(
                      delay: const Duration(seconds: 1),
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context).translate('menu.noData'),
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ),
                  );
                }
                // By default, show a loading spinner.
                return const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                );
              },
            )
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDateBottomSheet(context, availableDates, campuses, _setDate, api, date);
        },
        tooltip: AppLocalizations.of(context).translate('settings.settings'),
        child: const Icon(Icons.settings),
      ),
    );
  }
}

