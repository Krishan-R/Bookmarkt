import requests
from exts import db


class Book(db.Model):
    """A Book class which stores relevant information about each individual book.

    :params isbn: String containing ISBN of book
    :params googleID: String containing Google Books ID of book

    """
    isbn = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(50))
    author = db.Column(db.String(50))
    description = db.Column(db.String(2000))
    googleID = db.Column(db.String(20))

    def __init__(self, isbn="", googleID=""):
        """
        :param isbn: String containing ISBN of book
        :param googleID: String containing Google Books ID of book
        """

        self.isbn = isbn
        self.googleID = googleID

        self.title = ""
        self.author = ""
        self.description = ""

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

            parsedJson = r.json()

            if parsedJson["totalItems"] > 0:
                self.title = parsedJson["items"][0]["volumeInfo"]["title"]
                self.author = parsedJson["items"][0]["volumeInfo"]["authors"][0]
                self.description = parsedJson["items"][0]["volumeInfo"]["description"]
                self.googleID = parsedJson["items"][0]["id"]
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
                self.title = parsedJson["volumeInfo"]["title"]
                self.author = parsedJson["volumeInfo"]["authors"][0]
                self.description = parsedJson["volumeInfo"]["description"]
                self.isbn = parsedJson["volumeInfo"]["industryIdentifiers"][1]["identifier"]
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
                "author": self.author,
                "description": self.description,
                "pages": 200,
                "googleID": self.googleID
            }
        ]

    def __repr__(self):
        return '<Book %r>' % self.title
