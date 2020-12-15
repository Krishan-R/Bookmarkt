class Bookshelf:
    def __init__(self, bookshelfName):
        self.name = bookshelfName
        self.bookList = []

    def getBooks(self):
        for item in self.bookList:
            print(item)

    def addBook(self, book):
        self.bookList.append(book)
