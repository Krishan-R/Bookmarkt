class Bookshelf {
  String name;
  int bookshelfID;

  Bookshelf({
    this.name,
    this.bookshelfID
  });

  Bookshelf.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        bookshelfID = json["bookshelfID"];

}