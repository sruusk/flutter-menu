import 'package:flutter/material.dart';

import '../localisation.dart';
import '../update.dart';

class UpdateWidget extends StatelessWidget {
  const UpdateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Updater updater = Updater();

    return FutureBuilder<bool>(
      future: updater.isUpdateAvailable(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!) {
            return SafeArea(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('update.available'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () async {
                          updater.downloadAndInstallUpdate();
                        },
                      ),
                    ],
                  ),
                ),
              )
            );
          }
        }
        return Container();
      },
    );
  }
}
