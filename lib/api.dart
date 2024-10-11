import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';
import '../config/config.dart';

class MenuApi {
  DateTime selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  List<Restaurant> restaurants = [];

  Future<List<FilteredRestaurant>> get menu async{
    // Fetch the data from the API
    if(restaurants.isEmpty) {
      restaurants = await fetchMenu();
    }

    // Filter the restaurants based on the selected date
    List<FilteredRestaurant> filteredRestaurants = restaurants.map((restaurant) {
      var menuForSelectedDate = restaurant.menu.firstWhere((element) {
        var elementDate = DateTime(element.date.year, element.date.month, element.date.day);
        var comparisonDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        return elementDate == comparisonDate;
      }, orElse: () => Menu(date: selectedDate, fi: [], en: []));

      // If the restaurant has a non-empty menu for the selected date, include it in the filtered list
      if (menuForSelectedDate.en.isNotEmpty) {
        return FilteredRestaurant(
          name: restaurant.name,
          url: restaurant.url,
          campus: restaurant.campus,
          menu: menuForSelectedDate,
        );
      } else {
        return null;
      }
    }).where((restaurant) => restaurant != null).cast<FilteredRestaurant>().toList();

    return filteredRestaurants;
  }


  Future<List<Tuple2<DateTime, String>>> getAvailableDates() async {
    // Fetch the data from the API
    if(restaurants.isEmpty) {
      restaurants = await fetchMenu();
    }

    // Get the current date and the maximum date allowed (current date + 6 days)
    DateTime currentDate = DateTime.now();
    DateTime maxDate = currentDate.add(const Duration(days: 6));

    // Get the available dates from the menu
    List<Tuple2<DateTime, String>> availableDates = [];
    for (var restaurant in restaurants) {
      for (var menu in restaurant.menu) {
        var date = menu.date;

        // Include the date only if it is within the allowed range
        if (menu.fi.isNotEmpty && date.isBefore(maxDate.add(const Duration(days: 1)))) {
          availableDates.add(Tuple2(date, getDayOfWeek(date.weekday)));
        }
      }
    }

    // Remove duplicates
    availableDates = availableDates.toSet().toList();

    availableDates.sort((a, b) => a.item1.compareTo(b.item1));

    return availableDates;
  }

  Future<List<Campus>> getCampuses() async {
    // Fetch the data from the API
    if(restaurants.isEmpty) {
      restaurants = await fetchMenu();
    }

    // Get the campuses from the menu
    List<String> added = [];
    List<Campus> campuses = [];
    for (var restaurant in restaurants) {
      var campus = restaurant.campus;
      if(!added.contains(campus.toString())) {
        added.add(campus.toString());
        campuses.add(campus);
      }
    }

    return campuses;
  }

  static String getDayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return '';
    }
  }

  Future<List<Restaurant>> fetchMenu()  async {
    // fetch menu from api
    var url = Uri.parse(apiUrl);
    final response = await http.get(url, headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      var decoded = utf8.decode(response.bodyBytes);
      return List<Restaurant>.from(json.decode(decoded).map((x) => Restaurant.fromJson(x)));
    } else {
      throw Exception('Failed to load menu');
    }
  }
}

class Restaurant {
  final String name;
  final String url;
  final Campus campus;
  final List<Menu> menu;

  const Restaurant({
    required this.name,
    required this.url,
    required this.campus,
    required this.menu
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    var menuList = json['menu'] as List;

    var menu = menuList.map((i) => Menu.fromJson(i)).toList();
    menu.sort((a, b) => a.date.compareTo(b.date));

    return Restaurant(
      name: json['name'],
      url: json['url'],
      campus: Campus(campus: json['campus'], city: json['city']),
      menu: menu,
    );
  }

  @override
  String toString() {
    return 'Restaurant{name: $name, url: $url, campus: $campus, menu: $menu}';
  }
}

class Campus {
  final String campus;
  final String city;

  const Campus({
    required this.campus,
    required this.city
  });

  factory Campus.fromString(String campus) {
    var parts = campus.split(' - ');
    return Campus(campus: parts[0], city: parts[1]);
  }

  @override
  String toString() {
    return '$city - $campus';
  }
}

class FilteredRestaurant {
  final String name;
  final String url;
  final Campus campus;
  final Menu menu;

  const FilteredRestaurant({
    required this.name,
    required this.url,
    required this.campus,
    required this.menu
  });

  @override
  String toString() {
    return 'FilteredRestaurant{name: $name, url: $url, campus: $campus, menu: $menu}';
  }
}

class Menu {
  final DateTime date;
  final List<SubMenu> fi;
  final List<SubMenu> en;

  Menu({required this.date, required this.fi, required this.en});

  factory Menu.fromJson(Map<String, dynamic> json) {
    var fiList = json['fi'] as List;
    var enList = json['en'] as List;

    return Menu(
      date: DateTime.parse(json['date']),
      fi: fiList.map((i) => SubMenu.fromJson(i)).toList(),
      en: enList.map((i) => SubMenu.fromJson(i)).toList(),
    );
  }

  // Define the [] operator to access the menu in the selected language
  List<SubMenu> operator [](String language) {
    if (language == 'fi') {
      return fi;
    } else {
      return en;
    }
  }

  @override
  String toString() {
    return 'Menu{date: $date, fi: $fi, en: $en}';
  }
}

class SubMenu {
  final String name;
  final List<MenuItem> items;

  SubMenu({required this.name, required this.items});

  factory SubMenu.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;

    return SubMenu(
      name: json['name'],
      items: itemsList.map((i) => MenuItem.fromJson(i)).toList(),
    );
  }

  @override
  String toString() {
    return 'SubMenu{name: $name, items: $items}';
  }
}

class MenuItem {
  final String name;
  final String? diets;
  final String? ingredients;

  MenuItem({required this.name, required this.diets, required this.ingredients});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['name'],
      diets: json['diets'],
      ingredients: json['ingredients'],
    );
  }

  @override
  String toString() {
    return 'MenuItem{name: $name, diets: $diets, ingredients: $ingredients}';
  }
}
