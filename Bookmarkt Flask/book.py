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
        if self.isbn is not None and self.isbn != "":
            self.isbn = str(self.isbn).replace("-", "").replace(" ", "")
            try:
                self.isbn = int(self.isbn)
            except ValueError:
                pass

        self.googleID = googleID

        self.title = title
        self.authorName = author
        self.description = description
        self.thumbnail = "Assets/default.jpg"
        self.totalPages = totalPages
        self.publishedDate = publishedDate
        self.selfLink = selfLink
        self.automaticallyScraped = False

        if self.selfLink is not None:
            self.__scrapeFromSelfLink()
        elif self.isbn != "":
            self.__scrapeBookDataISBN()
        elif self.googleID != "":
            self.__scrapeBookDataGoogleID()
        else:
            print("no isbn or google books ID provided, automatic scraping will not occur")

    def toJson(self):
        """Returns a Json containing relevant details"""

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

        if self.isbn is not None and self.isbn != "":
            # Normalize ISBN: remove hyphens and spaces
            normalized_isbn = str(self.isbn).replace("-", "").replace(" ", "")

            apiKey = "AIzaSyAYwN0pTwSuP3JtnxQSiKQOPE5MwN95Mb0"
            orderBy = "relevance"

            # Use only one request with the API key
            r = requests.get(
                f"https://www.googleapis.com/books/v1/volumes?q=isbn:{normalized_isbn}&orderBy={orderBy}&key={apiKey}")

            if r.status_code != 200:
                print(f"Error from Google Books API: {r.status_code}. Response: {r.text}")
                # Fallback to no-key request if 429 or 400 (expired key)
                if r.status_code in [400, 429]:
                    r = requests.get(f"https://www.googleapis.com/books/v1/volumes?q=isbn:{normalized_isbn}&orderBy={orderBy}")

            parsedJson = r.json()

            if "error" in parsedJson:
                print(f"Google Books API returned an error: {parsedJson['error'].get('message')}")
                # We don't return here yet, we might want to try fallback search if it was a 429/400
                if r.status_code not in [400, 429]:
                    return

            # Fallback: If no items found with isbn: prefix, try a plain search
            if parsedJson.get("totalItems", 0) == 0:
                print(f"No items found with isbn: prefix for {normalized_isbn}, trying plain search")
                r = requests.get(f"https://www.googleapis.com/books/v1/volumes?q={normalized_isbn}&orderBy={orderBy}&key={apiKey}")
                if r.status_code != 200 and r.status_code in [400, 429]:
                    r = requests.get(f"https://www.googleapis.com/books/v1/volumes?q={normalized_isbn}&orderBy={orderBy}")
                parsedJson = r.json()

            if parsedJson.get("totalItems", 0) > 0 and "items" in parsedJson:
                try:
                    # Look through results to find a matching ISBN
                    matching_item = None
                    for item in parsedJson["items"]:
                        volumeInfo = item.get("volumeInfo", {})
                        identifiers = [id_obj.get("identifier") for id_obj in volumeInfo.get("industryIdentifiers", [])]
                        normalized_identifiers = [id.replace("-", "").replace(" ", "") for id in identifiers if id]
                        if normalized_isbn in normalized_identifiers:
                            matching_item = item
                            break
                    
                    if matching_item:
                        volumeInfo = matching_item["volumeInfo"]
                        self.title = volumeInfo.get("title")
                        authors = volumeInfo.get("authors", [])
                        if authors:
                            self.authorName = authors[0].replace(".", "").title()
                        self.description = volumeInfo.get("description")
                        self.googleID = matching_item.get("id")
                        self.totalPages = volumeInfo.get("pageCount")
                        self.publishedDate = volumeInfo.get("publishedDate")

                        # standardise publishedDate
                        if self.publishedDate:
                            if len(self.publishedDate) == 4:
                                self.publishedDate = f"{self.publishedDate}-01-01"
                            elif len(self.publishedDate) == 7:
                                self.publishedDate = f"{self.publishedDate}-01"

                        # store image locally
                        imageLinks = volumeInfo.get("imageLinks")
                        if imageLinks and "thumbnail" in imageLinks:
                            try:
                                urllib.request.urlretrieve(imageLinks["thumbnail"],
                                                           f"Assets/Thumbnails/{self.isbn}.jpg")
                                self.thumbnail = f"Assets/Thumbnails/{self.isbn}.jpg"
                            except Exception as e:
                                print(f"Error downloading thumbnail: {e}")

                        self.addBookToAuthor()

                        if self.authorName is None or self.totalPages is None:
                            self.automaticallyScraped = False
                        else:
                            self.automaticallyScraped = True

                    else:
                        print(f"book not found with isbn: {self.isbn}. Not scraping from Google Books")
                except (IndexError, KeyError) as e:
                    print(f"There was an issue scraping from google: {e}")
            else:
                print(f"book not found with isbn: {self.isbn}")
                if self.authorName is not None:
                    self.addBookToAuthor()
        else:
            print("isbn empty")

    def __scrapeBookDataGoogleID(self):
        """Adds relevant book fields from information retrieved by searching Google Books API on Google Books API"""

        if self.googleID is not None and self.googleID != "":

            apiKey = "AIzaSyBu5i0kpWKfoJ0Juhg5lhpYCU5Xonodo8g"

            r = requests.get(
                f"https://www.googleapis.com/books/v1/volumes/{self.googleID}?key={apiKey}")

            if r.status_code != 200:
                print(f"Error from Google Books API: {r.status_code}")
                if r.status_code in [400, 429]:
                    r = requests.get(f"https://www.googleapis.com/books/v1/volumes/{self.googleID}")

            parsedJson = r.json()

            try:
                volumeInfo = parsedJson.get("volumeInfo")
                if not volumeInfo:
                    print(f"book not found with google ID: {self.googleID}")
                    return

                self.title = volumeInfo.get("title")
                authors = volumeInfo.get("authors", [])
                if authors:
                    self.authorName = authors[0]
                self.description = volumeInfo.get("description")
                
                # Robust ISBN extraction
                identifiers = volumeInfo.get("industryIdentifiers", [])
                for ident in identifiers:
                    if ident.get("type") == "ISBN_13":
                        self.isbn = int(ident.get("identifier"))
                        break
                else:
                    if identifiers:
                        try:
                            self.isbn = int(identifiers[0].get("identifier"))
                        except ValueError:
                            pass

                self.addBookToAuthor()
            except Exception as e:
                print(f"Error processing Google Books response: {e}")

        else:
            print("google ID empty")

    def __scrapeFromSelfLink(self):
        """Adds relevant book fields from information retrieved from a direct link to a Google Books API response"""

        r = requests.get(self.selfLink)
        if r.status_code != 200:
            print(f"Error fetching selfLink: {r.status_code}")
            return

        parsedJson = r.json()
        volumeInfo = parsedJson.get("volumeInfo")
        if not volumeInfo:
            print("No volumeInfo found in selfLink response")
            return

        # ISBN
        for ident in volumeInfo.get("industryIdentifiers", []):
            if ident.get("type") == "ISBN_13":
                try:
                    self.isbn = int(ident.get("identifier"))
                except (ValueError, TypeError):
                    pass

        self.title = volumeInfo.get("title")
        authors = volumeInfo.get("authors", [])
        if authors:
            self.authorName = authors[0]
        self.description = volumeInfo.get("description")
        self.totalPages = volumeInfo.get("pageCount")
        self.publishedDate = volumeInfo.get("publishedDate")
        self.googleID = parsedJson.get("id")

        # standardise publishedDate
        if self.publishedDate:
            if len(self.publishedDate) == 4:
                self.publishedDate = f"{self.publishedDate}-01-01"
            elif len(self.publishedDate) == 7:
                self.publishedDate = f"{self.publishedDate}-01"

        # store image locally
        imageLinks = volumeInfo.get("imageLinks")
        if imageLinks and "thumbnail" in imageLinks:
            try:
                urllib.request.urlretrieve(imageLinks["thumbnail"],
                                           f"Assets/Thumbnails/{self.isbn}.jpg")
                self.thumbnail = f"Assets/Thumbnails/{self.isbn}.jpg"
            except Exception as e:
                print(f"Error downloading thumbnail: {e}")

    def addBookToAuthor(self):
        """Add author to Author and AuthorToBook table"""

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
