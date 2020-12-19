class Bookshelf:
    """Bookshelf class which stores multiple Book objects

    :param bookshelfName: Name of the bookshelf
    """

    def __init__(self, bookshelfName=""):
        """
        :param bookshelfName: Name of the bookshelf
        """

        self.name = bookshelfName
        self.bookList = []

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
