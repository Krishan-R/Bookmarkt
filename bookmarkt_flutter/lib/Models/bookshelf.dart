class Bookshelf {
  String name;
  int bookshelfID;
  String colour;

  Bookshelf({
    this.name,
    this.bookshelfID
  });

  Bookshelf.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        bookshelfID = json["bookshelfID"];

}