class Book {
  int bookInstanceID;
  String title;
  String author;
  String description;
  int ISBN;
  int userID;
  int bookshelfID;
  bool completed;
  int currentPage;
  int totalPages;
  String thumbnail;
  String publishedDate;
  int rating;
  int totalTimeRead;
  bool automaticallyScraped;
  DateTime completedDate;
  DateTime goalDate;
  String borrowingFrom;
  String borrowingTo;
  DateTime borrowingTime;

  Book(
      {this.bookInstanceID,
      this.title,
      this.author,
      this.description,
      this.ISBN,
      this.userID,
      this.bookshelfID,
      this.completed,
      this.currentPage,
      this.totalPages,
      this.thumbnail,
      this.publishedDate,
      this.rating,
      this.totalTimeRead,
      this.completedDate,
      this.goalDate,
      this.borrowingFrom,
      this.borrowingTo,
      this.borrowingTime,
      this.automaticallyScraped});

  Book.fromJson(Map<String, dynamic> json)
      : bookInstanceID = json["userData"]["bookInstanceID"],
        bookshelfID = json["userData"]["bookshelfID"],
        completed = json["userData"]["completed"],
        currentPage = json["userData"]["currentPage"],
        totalPages = json["bookData"]["totalPages"],
        userID = json["userData"]["userID"],
        ISBN = json["userData"]["isbn"],
        author = json["bookData"]["author"],
        description = json["bookData"]["description"],
        thumbnail = json["bookData"]["thumbnail"],
        publishedDate = json["bookData"]["publishedDate"],
        title = json["bookData"]["title"],
        totalTimeRead = json["userData"]["totalTimeRead"],
        rating = json["userData"]["rating"],
        borrowingFrom = json["userData"]["borrowingFrom"],
        borrowingTo = json["userData"]["borrowingTo"],
        borrowingTime = json["userData"]["borrowingTime"] == null ? null : DateTime.parse(json["userData"]["borrowingTime"]),
        completedDate = json["userData"]["completedDate"] == null ? null : DateTime.parse(json["userData"]["completedDate"]),
        goalDate = json["userData"]["goalDate"] == null ? null : DateTime.parse(json["userData"]["goalDate"]),
        automaticallyScraped = json["bookData"]["automaticallyScraped"];

  Book.fromJsonBookData(Map<String, dynamic> json)
      : author = json["author"],
        description = json["description"],
        ISBN = json["isbn"],
        publishedDate = json["publishedDate"],
        thumbnail = json["thumbnail"],
        title = json["title"],
        totalPages = json["totalPages"],
        automaticallyScraped = json["automaticallyScraped"];
}
