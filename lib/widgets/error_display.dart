import 'package:flutter/material.dart';
import '../localisation.dart';

class ErrorDisplay extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const ErrorDisplay({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context).translate('menu.error'),
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onRetry,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context).translate('menu.retry'))
              ],
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300), // Set a max width
                child: ExpansionTile(
                  title: Text(AppLocalizations.of(context).translate('menu.errorDetails')),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  collapsedBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(error.toString()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
