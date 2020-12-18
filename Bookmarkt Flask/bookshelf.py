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

    def getBooks(self) -> list:
        """retrieves all the books in the bookshelf

        :return: List of Book objects
        """

        return self.bookList

    def addBook(self, book):
        """Adds a Book object to the bookshelf

        :param book: Book Object to be added"""

        self.bookList.append(book)
