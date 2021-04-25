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
    authorName = db.Column(db.String(50))
    description = db.Column(db.String(2000))
    googleID = db.Column(db.String(20))
    thumbnail = db.Column(db.String(256))
    totalPages = db.Column(db.Integer)
    publishedDate = db.Column(db.String(16))
    automaticallyScraped = db.Column(db.Boolean, default=False)

    def __init__(self, isbn=None, googleID=None, title=None, description=None, totalPages=1, author=None, publishedDate=None,
                 selfLink=None):
        """
        :param isbn: String containing ISBN of book
        :param googleID: String containing Google Books ID of book
        """

        self.isbn = isbn
        self.googleID = googleID

        self.title = title
        self.authorName = author
        self.description = description
        self.thumbnail = "Assets/default.jpg"
        self.totalPages = totalPages
        self.publishedDate = publishedDate
        self.selfLink = selfLink

        if self.selfLink is not None:
            self.__scrapeFromSelfLink()
        elif self.isbn != "":
            self.__scrapeBookDataISBN()
        elif self.googleID != "":
            self.__scrapeBookDataGoogleID()
        else:
            print("no isbn or google books ID provided, automatic scraping will not occur")

    def toJson(self):
        return {
            "isbn": self.isbn,
            "title": self.title,
            "description": self.description,
            "author": self.authorName,
            "googleID": self.googleID,
            "thumbnail": self.thumbnail,
            "totalPages": self.totalPages,
            "publishedDate": self.publishedDate,
            "automaticallyScraped": self.automaticallyScraped
        }

    def __scrapeBookDataISBN(self):
        """Adds relevant book fields from information retrieved by searching ISBN on Google Books API"""

        if self.isbn is not None or self.isbn != "":

            apiKey = "AIzaSyBu5i0kpWKfoJ0Juhg5lhpYCU5Xonodo8g"
            orderBy = "relevance"

            r = requests.get(
                f"https://www.googleapis.com/books/v1/volumes?q=isbn:{self.isbn}&orderBy={orderBy}&key={apiKey}")

            r = requests.get(
                f"https://www.googleapis.com/books/v1/volumes?q=ISBN:{self.isbn}&orderBy={orderBy}&key={apiKey}")

            r = requests.get(
                f"https://www.googleapis.com/books/v1/volumes?q=isbn:{self.isbn}&orderBy={orderBy}")

            parsedJson = r.json()

            if parsedJson["totalItems"] > 0:
                try:
                    if parsedJson["items"][0]["volumeInfo"]["industryIdentifiers"][0]["identifier"] == self.isbn or \
                            parsedJson["items"][0]["volumeInfo"]["industryIdentifiers"][1]["identifier"] == self.isbn:
                        self.title = parsedJson["items"][0]["volumeInfo"]["title"]
                        self.authorName = parsedJson["items"][0]["volumeInfo"]["authors"][0].replace(".", "").title()
                        self.description = parsedJson["items"][0]["volumeInfo"]["description"]
                        self.googleID = parsedJson["items"][0]["id"]
                        self.totalPages = parsedJson["items"][0]["volumeInfo"]["pageCount"]
                        self.publishedDate = parsedJson["items"][0]["volumeInfo"]["publishedDate"]

                        # standardise publishedDate
                        if len(self.publishedDate) == 4:
                            self.publishedDate = f"{self.publishedDate}-01-01"
                        elif len(self.publishedDate) == 7:
                            self.publishedDate = f"{self.publishedDate}-01"

                        # store image locally
                        urllib.request.urlretrieve(parsedJson["items"][0]["volumeInfo"]["imageLinks"]["thumbnail"],
                                                   f"Assets/Thumbnails/{self.isbn}.jpg")
                        self.thumbnail = f"Assets/Thumbnails/{self.isbn}.jpg"

                        self.addBookToAuthor()

                        if self.authorName is None or self.totalPages is None:
                            self.automaticallyScraped = False
                        else:
                            self.automaticallyScraped = True

                    else:
                        print(f"book not found with isbn: {self.isbn}. Not scraping from Google Books")
                except IndexError:
                    print("There was an issue scraping from google")
            else:
                print(f"book not found with isbn: {self.isbn}")
                if self.authorName is not None:
                    self.addBookToAuthor()
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

                self.addBookToAuthor()
            except KeyError:
                print(f"book not found with google ID: {self.googleID}")

        else:
            print("google ID empty")

    def __scrapeFromSelfLink(self):

        r = requests.get(self.selfLink)
        parsedJson = r.json()

        # ISBN
        for ident in parsedJson["volumeInfo"]["industryIdentifiers"]:
            if ident["type"] == "ISBN_13":
                self.isbn = int(ident["identifier"])

        self.title = parsedJson["volumeInfo"]["title"]
        if parsedJson.get("volumeInfo").get("authors") is not None:
            self.authorName = parsedJson["volumeInfo"]["authors"][0]
        self.description = parsedJson.get("volumeInfo").get("description")
        self.totalPages = parsedJson.get("volumeInfo").get("pageCount")
        self.publishedDate = parsedJson.get("volumeInfo").get("publishedDate")
        self.googleID = parsedJson["id"]

        # standardise publishedDate
        if self.publishedDate is not None:
            if len(self.publishedDate) == 4:
                self.publishedDate = f"{self.publishedDate}-01-01"
            elif len(self.publishedDate) == 7:
                self.publishedDate = f"{self.publishedDate}-01"

        # store image locally
        urllib.request.urlretrieve(parsedJson["volumeInfo"]["imageLinks"]["thumbnail"],
                                   f"Assets/Thumbnails/{self.isbn}.jpg")
        self.thumbnail = f"Assets/Thumbnails/{self.isbn}.jpg"

        # in case user needs to change details
        # self.automaticallyScraped = False

    def addBookToAuthor(self):

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
