import 'package:flutter/material.dart';

class MenuAnchorWidget extends StatelessWidget {
  final List<Widget> menuChildren;
  final String buttonText;
  final Function() onPressed;

  const MenuAnchorWidget({
    super.key,
    required this.menuChildren,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      menuChildren: menuChildren,
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return TextButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.primaryContainer),
            shadowColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.shadow),
            elevation: WidgetStateProperty.all<double>(1),
          ),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
            onPressed();
          },
          child: Row(
            children: [
              Text(
                buttonText,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        );
      },
    );
  }
}

class SettingsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsCard({required this.title, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Theme.of(context).colorScheme.shadow,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 15.0, right: 15.0, bottom: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                child,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
