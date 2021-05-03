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

1. Download the mobile application files locally

`git clone https://campus.cs.le.ac.uk/gitlab/ug_project/20-21/kr217.git && cd "kr217/bookmarkt_flutter"`

2. Run `flutter doctor` to ensure that your Flutter installation is valid
3. Run `flutter build apk` to build the release version of the APK. This will automatically run `flutter pub get` which retrieves all the necessary packages

The APK will be built, with its output being printed in the terminal. Usually this is `build/app/outputs/flutter-apk/app-release.apk`

## Compatibility

Flutter naturally supports Android SDK 16 (Android 4.1) and higher, however due to particular Android functions and APIs that have been utilised, the minimum SDK version that Bookmarkt supports is 21 (Android 5). This means that any phone that is running at least Android 5 should be able to install and run the application without any issues.

When writing and testing the application, a Pixel 3 XL and Pixel 4 XL both with SDK 28 (Android 9) were used, as well as a OnePlus 6T and OnePlus 7 Pro running Android 10.

## Relevant Folders

- .gradle - Contains gradle build files
- android - Contains relevant auto-generated Android files
- ios - Contains relevant auto-generated iOS files
- lib/Assets - Contains Assets used by the application, such as the icon
- lib/Models - Contains Dart classes, such as User and Book
- lib/Pages - Contains all the application Pages written in Dart
- lib/Widgets - Contains all the independent and reusable Dart widgets


## Relevant Files

- lib/Assets/BookmarktLogo.png - A 2048x2048 transparent copy of the Bookmarkt logo
- lib/Assets/DrawerImgOriginal - The original copy of the image used in the Drawer
- lib/Assets/DrawerImg - The cropped and edited Drawer image
- lib/Models/API requests.dart - Contains all the API requests sent by the mobile application to the server.
- lib/Models/book.dart - The Book class and its methods
- lib/Models/bookshelf.dart - The Bookshelf class and its methods
- lib/Models/navigatorArguments.dart - The NavigatorArguments class which transfers data between pages and widgets
- lib/Models/readingSession.dart - The ReadingSession class and its methods
- lib/Models/user.dart - The User class and its methods
- lib/Pages/addBooksToLibrary.dart - Page that allows users to select which books they want to add to a specific bookshelf
- lib/Pages/allBooks.dart - Page that shows every book a user has
- lib/Pages/bookshelf.dart - Page that shows every book in a bookshelf
- lib/Pages/bookView.dart - Page that shows information about a specific book
- lib/Pages/drawer.dart - Side menu drawer that allows for navigation
- lib/Pages/findServer.dart - Page that allows the user to enter Bookmarkt server URL
- lib/Pages/homepage.dart - Dashboard page that shows recently read books, unread books, and reading graphs
- lib/Pages/library.dart - Page that shows all the bookshelves that a user has
- lib/Pages/loading.dart - Initial page that is used to route the application to the relevant page
- lib/Pages/login.dart - Page that allows the user to log into the Bookmarkt server
- lib/Pages/readingSessionHistory.dart - Contains the page that shows all reading sessions as well as book-specific reading sessions
- lib/Pages/readingSessions.dart - Page that allows users to start reading sessions
- lib/Pages/searchBook.dart - Page that allows users to search for a book to add to their library
- lib/Pages/signUp.dart - Page that allows users to sign up to a Bookmarkt server
- lib/Widgets/addBookAlert.dart - Widget that brings up an alert dialog for a user to enter an ISBN to add a book 
- lib/Widgets/addBookData.dart - Widget that is shown when a user wants to add or edit a book
- lib/Widgets/bookListView.dart - Widget that shows a list of cards of Books that is shown in allBooks.dart and bookshelf.dart
- lib/Widgets/readingSessionCard.dart - Widget that shows a card containing reading session information
- lib/main.dart - The main dart file that is ran when the application is started
- .README - This README file
- bookmarkt.apk - The Bookmarkt APK
- pubspec.lock - File that locks packages to a specific version
- pubspec.yaml - File that lists package dependencies and other metadata

## Screenshots

### splashScreen: 

![splashScreen](../App%20Screenshots/misc/splash%20screen.png)

### findServer: 

![findServer](../App%20Screenshots/misc/findServer%20with%20SafeArea.png)

### login: 

![login](../App%20Screenshots/misc/login.png)

### register: 

![register](../App%20Screenshots/misc/register.png)

### drawer: 

![drawer](../App%20Screenshots/misc/drawer.png)

### addBook: 

![addBook](../App%20Screenshots/addBook/addBook.png)

### bookView: 

![bookView](../App%20Screenshots/bookView/bookView%20partially%20read.png)

### dashboard: 

![dashboard](../App%20Screenshots/dashboard/dashboard%20with%20data1.png)

### library: 

![library](../App%20Screenshots/library/library.png)

### bookshelf: 

![bookshelf](../App%20Screenshots/bookshelf/bookshelf.png)

### allBooks: 

![allBooks](../App%20Screenshots/books/books.png)

### readingSession timed: 

![readingSession timed](../App%20Screenshots/readingSessions/readingSessions%20timed.png)

### readingSession untimed: 

![readingSession untimed](../App%20Screenshots/readingSessions/readingSessions%20untimed.png)

### readingSessionHistory: 

![readingSessionHistory](../App%20Screenshots/readingSessionsHistory/readingSessions.png)
