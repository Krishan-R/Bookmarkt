class Bookshelf {
  String name;
  int bookshelfID;
  int bookCount;
  String colour;

  Bookshelf({
    this.name,
    this.bookshelfID,
    this.bookCount
  });

  Bookshelf.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        bookCount = json["bookCount"],
        bookshelfID = json["bookshelfID"];

}