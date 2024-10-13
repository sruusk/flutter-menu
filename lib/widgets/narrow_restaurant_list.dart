import 'package:flutter/material.dart';
import 'package:lunch_menu/widgets/restaurant_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../api.dart';

class NarrowRestaurantList extends StatelessWidget {
  NarrowRestaurantList({
    super.key,
    required this.data,
  });

  final List<FilteredRestaurant>? data;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        data!.length > 1 ? SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: data!.length,
              effect: SwapEffect(
                activeDotColor: Theme.of(context).colorScheme.primaryContainer,
                dotColor: Theme.of(context).colorScheme.secondaryContainer,
                dotWidth: 15.0,
                dotHeight: 15.0,
              ),
              onDotClicked: (index) => _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
            ),
          ),
        ) : SafeArea(child: Container( height: 10,)),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: data!.length,
            itemBuilder: (context, index) {
              return RestaurantWidget(restaurant: data![index]);
            },
          ),
        ),
      ],
    );
  }
}
