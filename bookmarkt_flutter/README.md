# Bookmarkt Mobile Application
This folder holds all the code for the Bookmarkt mobile application written using Flutter. API requests are sent and their responses are handled by this application. Instructions on installation can be seen below.

## Installation

To install this application,
1. Download the APK file on your mobile Android device
2. Navigate to the download directory in your phone's file browser
3. Run in the APK to install the application
4. Accept any privilege requests
5. The app should now be installed

## Building the APK
To build the APK from the source code, you need to have Flutter installed ([instructions can be found here](https://flutter.dev/docs/get-started/install)).

1. Run `flutter doctor` in a command prompt/terminal in the bookmarkt_flutter directory to ensure that your installation is valid
2. Run `flutter build apk` to build the release version of the APK. This will automatically run `flutter pub get` which retrieves all the necessary packages
3. The APK will be built, with its output being printed in the terminal. Usually this is `build/app/outputs/flutter-apk`
4. The command `flutter clean` will remove the build folder in case of corruption