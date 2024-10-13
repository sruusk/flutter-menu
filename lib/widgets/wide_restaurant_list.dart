import 'package:flutter/material.dart';
import 'package:lunch_menu/widgets/restaurant_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../api.dart';

class WideRestaurantView extends StatelessWidget {
  WideRestaurantView({
    super.key,
    required this.data,
  });

  final List<FilteredRestaurant>? data;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    // Get the number of columns based on the screen width
    int columns = (MediaQuery.of(context).size.width / 400).floor();
    return Column(
      children: [
        data!.length > columns ? SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: data!.length % columns == 0 ? data!.length ~/ columns : data!.length ~/ columns + 1,
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
            itemCount: data!.length % columns == 0 ? data!.length ~/ columns : data!.length ~/ columns + 1,
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < columns; i++)
                      if (index * columns + i < data!.length)
                        Expanded(
                          child: RestaurantWidget(restaurant: data![index * columns + i], scrollable: false),
                        )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
