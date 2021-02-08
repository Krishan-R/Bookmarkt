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
      this.thumbnail});

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
        title = json["bookData"]["title"];
}
