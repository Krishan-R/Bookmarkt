import requests


class Book:
    def __init__(self, isbn):
        self.isbn = isbn

        self.title = ""
        self.author = ""
        self.description = ""
        self.googleID = ""

        self.__scrapeBookDataISBN()

    def __scrapeBookDataISBN(self):

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
