from exts import db


class Bookshelf(db.Model):
    """Bookshelf class which stores multiple Book objects

    :param bookshelfName: Name of the bookshelf
    """

    __tablename__ = "Bookshelf"
    bookshelfID = db.Column(db.Integer, unique=True, primary_key=True)
    name = db.Column(db.String(50))
    userID = db.Column(db.Integer, db.ForeignKey("User.id"), nullable=False)
    user = db.relationship("User", backref=db.backref("posts", lazy=True))
    colour = db.Column(db.String(10))

    def __init__(self, bookshelfName="", userID="", colour=None):
        """
        :param bookshelfName: Name of the bookshelf
        """

        self.name = bookshelfName
        self.bookList = []
        self.userID = userID
        self.colour = colour

    def getBooks(self):
        """retrieves all the books in the bookshelf

        :return: List of Book objects
        """

        return self.bookList

    def addBook(self, book):
        """Adds a Book object to the bookshelf

        :param book: Book Object to be added"""

        self.bookList.append(book)

    def __add__(self, book):
        """Adds a Book object to the bookshelf

        :param book: Book Object to be added"""

        self.addBook(book)

        return self

    def copy(self, oldBookshelf):
        """Copies Book objects from a Bookshelf

        :param oldBookshelf: Bookshelf to be copied
        """

        self.bookList = []

        for book in oldBookshelf.getBooks():
            self.addBook(book)

    def copy(self):
        """Returns a Bookshelf object with the same Books stored as the original object

        :return: Bookshelf containing books
        """

        bookshelf = Bookshelf()

        bookshelf.bookList = []

        for book in self.getBooks():
            bookshelf.addBook(book)

        return bookshelf
