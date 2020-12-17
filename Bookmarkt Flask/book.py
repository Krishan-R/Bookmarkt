import requests


class Book:
    def __init__(self, isbn="", googleID=""):
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

        if self.isbn is not None or self.isbn != "":

            apiKey = "AIzaSyBu5i0kpWKfoJ0Juhg5lhpYCU5Xonodo8g"
            orderBy = "relevance"

            r = requests.get(
                f"https://www.googleapis.com/books/v1/volumes?q=isbn:{self.isbn}&orderBy={orderBy}&key={apiKey}")

            parsedJson = r.json()

            if parsedJson["totalItems"] > 0:
                self.title = parsedJson["items"][0]["volumeInfo"]["title"]
                self.author = parsedJson["items"][0]["volumeInfo"]["authors"]
                self.description = parsedJson["items"][0]["volumeInfo"]["description"]
                self.googleID = parsedJson["items"][0]["id"]
            else:
                print(f"book not found with isbn: {self.isbn}")
        else:
            print("isbn empty")

    def __scrapeBookDataGoogleID(self):

        if self.googleID is not None or self.googleID != "":

            apiKey = "AIzaSyBu5i0kpWKfoJ0Juhg5lhpYCU5Xonodo8g"

            r = requests.get(
                f"https://www.googleapis.com/books/v1/volumes/{self.googleID}&key={apiKey}")

            parsedJson = r.json()

            try:
                self.title = parsedJson["volumeInfo"]["title"]
                self.author = parsedJson["volumeInfo"]["authors"]
                self.description = parsedJson["volumeInfo"]["description"]
                self.isbn = parsedJson["volumeInfo"]["industryIdentifiers"][1]["identifier"]
            except KeyError:
                print(f"book not found with google ID: {self.googleID}")

        else:
            print("google ID empty")


    def getData(self):
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

    def __str__(self):
        return self.title
