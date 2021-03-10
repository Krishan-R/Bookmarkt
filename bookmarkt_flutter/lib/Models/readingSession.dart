class ReadingSession {

  int readingSessionID;
  int bookInstanceID;
  int userID;
  int pagesRead;
  int timeRead;
  DateTime date;

  ReadingSession({
    this.readingSessionID,
    this.bookInstanceID,
    this.userID,
    this.pagesRead,
    this.timeRead,
    this.date,
  });

  ReadingSession.fromJson(Map<String, dynamic> json)
      : readingSessionID = json["readingSessionID"],
        bookInstanceID = json["bookInstanceID"],
        userID = json["userID"],
        pagesRead = json["pagesRead"],
        timeRead = json["timeRead"],
        date = DateTime.parse(json["date"]);
}