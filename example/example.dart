import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class AweseomSnackBarExample extends StatelessWidget {
  const AweseomSnackBarExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('Show Awesome SnackBar'),
              onPressed: () {
                AwesomeSnackbarContent(
                  title: 'On Snap!',
                  message:
                      'This is an example error message that will be shown in the body of snackbar! With some large text message to show with full content available.',

                  /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                  contentType: ContentType.failure,
                ).show(context);
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Show Awesome Material Banner'),
              onPressed: () {
                AwesomeSnackbarContent(
                  title: 'Oh Hey!!',
                  message: 'This is an example error message that will be shown in the body of materialBanner!',

                  /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                  contentType: ContentType.success,
                  // to configure for material banner
                ).show(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
