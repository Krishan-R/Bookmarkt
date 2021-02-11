import requests
import urllib.request
from exts import db
from author import Author, AuthorToBook


class Book(db.Model):
    """A Book class which stores relevant information about each individual book.

    :params isbn: String containing ISBN of book
    :params googleID: String containing Google Books ID of book

    """

    __tablename__ = "Book"
    isbn = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(50))
    # authorID = db.Column(db.Integer, db.ForeignKey("author.authorID"))
    # author = db.relationship("Author", backref=db.backref("author_posts", lazy=True))
    authorName = db.Column(db.String(50))
    description = db.Column(db.String(2000))
    googleID = db.Column(db.String(20))
    thumbnail = db.Column(db.String(256))
    totalPages = db.Column(db.Integer)
    publishedDate = db.Column(db.String(16))

    def __init__(self, isbn="", googleID="", title="", description="", totalPages="", author=""):
        """
        :param isbn: String containing ISBN of book
        :param googleID: String containing Google Books ID of book
        """

        self.isbn = isbn
        self.googleID = googleID

        self.title = title
        self.authorName = author
        self.authorID = None
        self.description = description
        self.thumbnail = ""
        self.totalPages = totalPages

        if self.isbn != "":
            self.__scrapeBookDataISBN()
        elif self.googleID != "":
            self.__scrapeBookDataGoogleID()
        else:
            print("no isbn or google books ID provided, automatic scraping will not occur")

    def __scrapeBookDataISBN(self):
        """Adds relevant book fields from information retrieved by searching ISBN on Google Books API"""

        if self.isbn is not None or self.isbn != "":

            apiKey = "AIzaSyBu5i0kpWKfoJ0Juhg5lhpYCU5Xonodo8g"
            orderBy = "relevance"

            r = requests.get(
                f"https://www.googleapis.com/books/v1/volumes?q=isbn:{self.isbn}&orderBy={orderBy}&key={apiKey}")

            r = requests.get(
                f"https://www.googleapis.com/books/v1/volumes?q=ISBN:{self.isbn}&orderBy={orderBy}&key={apiKey}")

            parsedJson = r.json()

            if parsedJson["totalItems"] > 0:

                if parsedJson["items"][0]["volumeInfo"]["industryIdentifiers"][0]["identifier"] == self.isbn or parsedJson["items"][0]["volumeInfo"]["industryIdentifiers"][1]["identifier"] == self.isbn:
                    self.title = parsedJson["items"][0]["volumeInfo"]["title"]
                    self.authorName = parsedJson["items"][0]["volumeInfo"]["authors"][0].replace(".", "").title()
                    self.description = parsedJson["items"][0]["volumeInfo"]["description"]
                    self.googleID = parsedJson["items"][0]["id"]
                    self.totalPages = parsedJson["items"][0]["volumeInfo"]["pageCount"]
                    self.publishedDate = parsedJson["items"][0]["volumeInfo"]["publishedDate"]

                    #store image locally
                    urllib.request.urlretrieve(parsedJson["items"][0]["volumeInfo"]["imageLinks"]["thumbnail"], f"Assets/bookThumbnails/{self.isbn}.jpg")
                    self.thumbnail = f"Assets/bookThumbnails/{self.isbn}.jpg"

                    self.__addBookToAuthor()
                else:
                    print(f"book not found with isbn: {self.isbn}. Not scraping fromn Google Books")

            else:
                print(f"book not found with isbn: {self.isbn}")
        else:
            print("isbn empty")

    def __scrapeBookDataGoogleID(self):
        """Adds relevant book fields from information retrieved by searching Google Books API on Google Books API"""

        if self.googleID is not None or self.googleID != "":

            apiKey = "AIzaSyBu5i0kpWKfoJ0Juhg5lhpYCU5Xonodo8g"

            r = requests.get(
                f"https://www.googleapis.com/books/v1/volumes/{self.googleID}&key={apiKey}")

            r = requests.get(
                f"https://www.googleapis.com/books/v1/volumes/{self.googleID}")

            parsedJson = r.json()

            try:
                self.title = parsedJson["items"][0]["volumeInfo"]["title"]
                self.authorName = parsedJson["items"][0]["volumeInfo"]["authors"][0]
                self.description = parsedJson["items"][0]["volumeInfo"]["description"]
                self.isbn = parsedJson["volumeInfo"]["industryIdentifiers"][1]["identifier"]

                self.__addBookToAuthor()
            except KeyError:
                print(f"book not found with google ID: {self.googleID}")

        else:
            print("google ID empty")

    def getData(self) -> list:
        """retrieves information about the Book object

        :return: List containing JSON of book information
        """

        return [
            {
                "isbn": self.isbn,
                "title": self.title,
                "author": self.authorName,
                "description": self.description,
                "pages": 200,
                "googleID": self.googleID
            }
        ]

    def __addBookToAuthor(self):

        # adds author to database if it doesnt already exist
        if Author.query.filter(Author.authorName == self.authorName).count() == 0:
            print(f"author ({self.authorName}) not in database")
            newAuthor = Author(self.authorName)
            db.session.add(newAuthor)
            db.session.commit()

        author = Author.query.filter(Author.authorName == self.authorName).first()
        author.books.append(self)
        db.session.commit()

    def __repr__(self):
        return '<Book %r>' % self.title
