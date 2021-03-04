import datetime

from pathlib import Path
import flask
from flask import request, jsonify, send_file
import hashlib
from user import User
from bookshelf import Bookshelf
from author import Author
from book import Book
from bookInstance import BookInstance
from authorToBook import AuthorToBook
from readingSession import ReadingSession

import os
from exts import db

app = flask.Flask(__name__)
app.config["DEBUG"] = True

if Path("/database").is_dir():
    file_path = "/database/database.db"
    app.config["SQLALCHEMY_DATABASE_URI"] = 'sqlite:///'+file_path

else:
    file_path = os.path.abspath(os.getcwd()) + "/database/database.db"

print(f"database path is {file_path}")
app.config["SQLALCHEMY_DATABASE_URI"] = 'sqlite:///'+file_path

db.init_app(app)


def encryptPassword(password):
    return hashlib.sha256(password.encode("utf-8")).hexdigest()


@app.route('/', methods=["GET"])
def home():

    print(f"database path is {file_path}")

    try:
        if len(os.listdir(file_path.replace("/database.db", ""))) != 1:
            print("cant find database file")
            db.drop_all()
            db.create_all()
    except FileNotFoundError:
        os.mkdir(file_path.replace("/database.db", ""))
        db.drop_all()
        db.create_all()
    except NotADirectoryError:
        os.mkdir(file_path.replace("/database.db", ""))
        db.drop_all()
        db.create_all()


    return "True", 200


@app.route('/users/all', methods=["GET"])
def getAllUsers():

    jsonList = []
    try:
        for user in User.query.all():
            jsonList.append({
                "id": user.id,
                "username": user.username,
                "email": user.email
            })
    except:
        print("error occured")

    return jsonify(jsonList), 200


@app.route('/users/<userID>', methods=["GET"])
def getSpecificUser(userID):

    if User.query.filter(User.id == userID).first() is None:
        return "User does not exist", 422

    jsonList = []
    try:
        for user in User.query.filter(User.id == userID):
            jsonList.append({
                "id": user.id,
                "username": user.username,
                "email": user.email
            })
    except:
        print("error occured")

    return jsonify(jsonList[0]), 200


@app.route('/users/<userID>/books/all', methods=["GET"])
def getAllUserBooks(userID):

    bookInstance = BookInstance.query.filter(BookInstance.userID == userID).first()
    if bookInstance is None:
        return "No books", 200

    JsonList = []

    for index, instance in enumerate(BookInstance.query.filter(BookInstance.userID == userID)):

        JsonList.append({"userData": {},
                         "bookData": {}})

        JsonList[index]["userData"] = {
            "isbn": instance.isbn,
            "bookInstanceID": instance.bookInstanceID,
            "currentPage": instance.currentPage,
            "completed": instance.completed,
            "userID": instance.userID,
            "bookshelfID": instance.bookshelfID,
            "rating": instance.rating,
            "totalTimeRead": instance.totalTimeRead
        }

        for book in Book.query.filter(Book.isbn == instance.isbn):
            JsonList[index]["bookData"] = {
                "isbn": book.isbn,
                "title": book.title,
                "description": book.description,
                "author": book.authorName,
                "thumbnail": book.thumbnail,
                "googleID": book.googleID,
                "totalPages": book.totalPages,
                "publishedDate": book.publishedDate,
                "automaticallyScraped": book.automaticallyScraped
            }

    return jsonify(JsonList), 200


@app.route("/users/<userID>/books/<bookInstanceID>", methods=["GET"])
def getSpecificUserBook(userID, bookInstanceID):

    userID = int(userID)
    bookInstanceID = int(bookInstanceID)

    bookInstance = BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).first()
    book = Book.query.filter(Book.isbn == bookInstance.isbn).first()

    if bookInstance is None:
        return "Book instance could not be found", 404

    if bookInstance.userID != userID:
        return "That book does not belong to user", 403

    json = {
        "userData": {},
        "bookData": {}
    }

    json["userData"] = {
        "isbn": bookInstance.isbn,
        "bookInstanceID": bookInstance.bookInstanceID,
        "currentPage": bookInstance.currentPage,
        "completed": bookInstance.completed,
        "userID": bookInstance.userID,
        "bookshelfID": bookInstance.bookshelfID,
        "rating": bookInstance.rating,
        "totalTimeRead": bookInstance.totalTimeRead
    }

    json["bookData"] = {
        "isbn": book.isbn,
        "title": book.title,
        "description": book.description,
        "author": book.authorName,
        "thumbnail": book.thumbnail,
        "googleID": book.googleID,
        "totalPages": book.totalPages,
        "publishedDate": book.publishedDate,
        "automaticallyScraped": book.automaticallyScraped
    }

    return jsonify(json), 200


@app.route("/bookinstance/all", methods=["GET"])
def getAllBookInstances():

    JsonList = []

    for index, instance in enumerate(BookInstance.query.all()):

        JsonList.append({"userData": {},
                         "bookData": {}})

        JsonList[index]["userData"] = {
            "isbn": instance.isbn,
            "bookInstanceID": instance.bookInstanceID,
            "currentPage": instance.currentPage,
            "completed": instance.completed,
            "userID": instance.userID,
            "bookshelfID": instance.bookshelfID,
            "rating": instance.rating,
            "totalTimeRead": instance.totalTimeRead
        }

        for book in Book.query.filter(Book.isbn == instance.isbn):
            JsonList[index]["bookData"] = {
                "isbn": book.isbn,
                "title": book.title,
                "description": book.description,
                "author": book.authorName,
                "googleID": book.googleID,
                "publishedDate": book.publishedDate,
                "automaticallyScraped": book.automaticallyScraped
            }

    return jsonify(JsonList), 200


@app.route("/users/<userID>/books/add", methods=["POST"])
def addUserBook(userID):

    isbn = request.args.get("isbn", None)
    currentPage = request.args.get("currentPage", None)
    completed = request.args.get("completed", None)
    bookshelfID = request.args.get("bookshelfID", None)
    rating = request.args.get("rating", 0)
    totalTimeRead = request.args.get("totalTimeRead", 0)
    title = request.args.get("title", None)
    author = request.args.get("author", None)
    publishedDate = request.args.get("publishedDate", None)
    description = request.args.get("description", None)
    totalPages = request.args.get("totalPages", 1)

    if currentPage is not None:
        try:
            currentPage = int(currentPage)
        except Exception as e:
            print(e)
            print("An Error has occurred")
            return "currentPage value not valid", 422
    else:
        currentPage = 0

    if completed is None or completed.lower() == "false":
        completed = False
    elif completed.lower() == "true":
        completed = True

    if bookshelfID is not None:
        try:
            bookshelfID = int(bookshelfID)

            #checks to see if bookshelf exists and belongs to that user
            bookshelf = Bookshelf.query.filter(Bookshelf.bookshelfID == bookshelfID).first()
            if bookshelf is None:
                return "Bookshelf does not not exist", 422

            if bookshelf.userID != int(userID):
                return "Bookshelf does not belong to that user", 403

        except Exception as e:
            print(e)
            print("An Error has occurred")
            return "bookshelfID is not valid", 422

    # check to see if book data is in database
    book = Book.query.filter(Book.isbn == isbn).first()
    if book is None:
        print("book not found, trying to scrape")
        newBook = Book(isbn=isbn,
                       title=title,
                       author=author,
                       description=description,
                       totalPages=totalPages,
                       publishedDate=publishedDate)
        db.session.add(newBook)
        db.session.commit()

    # if completed:
    #     currentPage = totalPages

    newBookInstance = BookInstance(isbn, userID, completed=completed, currentPage=currentPage, bookshelfID=bookshelfID, rating=rating, totalTimeRead=totalTimeRead)
    db.session.add(newBookInstance)
    db.session.commit()

    return "added new BookInstance", 201


@app.route('/users/<userID>/books/<bookInstanceID>/edit', methods=["PUT"])
def updateBookInstance(userID, bookInstanceID):

    userID = int(userID)

    currentPage = request.args.get("currentPage", None)
    completed = request.args.get("completed", None)
    bookshelfID = request.args.get("bookshelfID", None)
    rating = request.args.get("rating", None)
    totalTimeRead = request.args.get("totalTimeRead", None)
    bookInstance = BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).first()

    if bookInstance is None:
        return "Book Instance does not exist", 422

    # check if bookinstance belongs to that userid
    if bookInstance.userID != userID:
        print("Book instance does not belong to user")
        return f"Book Instance {bookInstanceID} does not belong to user {userID}", 403

    if currentPage is not None:
        try:
            currentPage = int(currentPage)
            bookInstance.currentPage = currentPage
        except Exception as e:
            print(e)
            print("An Error has occurred")

    if completed is not None and completed.lower() == "false":
        completed = False
        bookInstance.completed = completed
    elif completed is not None and completed.lower() == "true":
        completed = True
        bookInstance.completed = completed

    if rating is not None:
        try:
            bookInstance.rating = rating
        except:
            print("an error occurred changing rating of book instance")

    if totalTimeRead is not None:
        try:
            bookInstance.totalTimeRead = totalTimeRead
        except:
            print("an error occurred changing totalTimeRead of Book instance")

    if bookshelfID is not None:
        try:
            bookshelfID = int(bookshelfID)

            # check if bookshelfID belongs to userID
            bookshelf = Bookshelf.query.filter(Bookshelf.bookshelfID == bookshelfID).first()
            if bookshelf.userID != userID:
                print("Bookshelf does not belong to that user")
                return f"Bookshelf {bookshelfID} does not belong to user {userID}"

            bookInstance.bookshelfID = bookshelfID
        except Exception as e:
            print(e)
            print("An Error has occurred")

    db.session.commit()

    return f"Edited book instance {bookInstanceID}", 200


@app.route("/bookinstance/delete", methods=["DELETE"])
def deleteBookInstance():

    bookInstanceID = request.args.get("bookInstanceID", None)

    if BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).first() is None:
        return "Book Instance does not exist", 422

    BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).delete()
    db.session.commit()

    return f"deleted book instance id {bookInstanceID}", 200


@app.route("/users/<userID>/books/delete", methods=["DELETE"])
def deleteUserBookInstance(userID):

    bookInstanceID = request.args.get("bookInstanceID", None)

    bookInstance = BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).first()

    if bookInstance is None:
        return "Book Instance not found", 422

    # checks to see if book instance belongs to that user
    if bookInstance.userID != int(userID):
        return f"Book Instance {bookInstanceID} does not belong to user {userID}", 403

    BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).delete()
    db.session.commit()

    return f"deleted book instance", 200


@app.route("/users/<userID>/books/delete/all", methods=["DELETE"])
def deleteAllUserBook(userID):

    BookInstance.query.filter(BookInstance.userID == userID).delete()
    db.session.commit()

    return f"deleted all book instances from user {userID}", 200


@app.route("/users/<userID>/books/<bookInstanceID>/read", methods=["POST"])
def addReadingSession(userID, bookInstanceID):

    pagesRead = request.args.get("pagesRead", None)
    timeRead = request.args.get("timeRead", None)
    date = request.args.get("date", datetime.date.today())
    updateProgress = request.args.get("updateProgress", True)
    completed = request.args.get("completed", False)
    bookInstance = BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).first()

    try:
        dateObj = datetime.datetime.strptime(date, "%Y-%m-%d")
    except TypeError:
        dateObj = date

    if bookInstance.userID != int(userID):
        print(bookInstance.userID, bookInstance.book.title, userID)
        print("Book instance does not belong to user")
        return f"Book Instance {bookInstanceID} does not belong to user {userID}", 403

    if pagesRead is None:
        return "pagesRead missing", 422

    if timeRead is None:
        return "timeRead missing", 422

    if updateProgress == "false" or updateProgress == "False":
        updateProgress = False
    else:
        updateProgress = True

    if completed == "true" or completed == "True":
        completed = True
    else:
        completed = False

    readingSession = ReadingSession(bookInstanceID, pagesRead, timeRead, userID, dateObj)
    db.session.add(readingSession)

    pagesRead = int(pagesRead)
    timeRead = int(timeRead)
    bookInstance.totalTimeRead += timeRead

    # updates bookinstance object
    if updateProgress:
        bookInstance.currentPage += pagesRead
        bookInstance.completed = completed

    db.session.commit()

    return "added reading session", 201


@app.route('/users/add', methods=["POST"])
def addNewUser():

    newUsername = request.args.get("username", None)
    email = request.args.get("email", None)
    password = request.args.get("password", None)

    if newUsername is None:
        return "username is missing", 422
    if email is None:
        return "email is missing", 422
    if password is None:
        return "password is missing", 422

    user = User.query.filter(User.email == email).first()

    if user is not None:
        return "There is already an account associated with this email", 409

    user = User.query.filter(User.username == newUsername).first()

    if user is not None:
        return "username already exists", 409

    newUser = User(username=newUsername, email=email, password=encryptPassword(password))
    db.session.add(newUser)
    db.session.commit()

    return "added new User", 201


@app.route("/users/<userID>/delete", methods=["DELETE"])
def deleteUser(userID):

    User.query.filter(User.id == userID).delete()
    Bookshelf.query.filter(Bookshelf.userID == userID).delete()
    BookInstance.query.filter(BookInstance.userID == userID).delete()

    db.session.commit()

    return f"deleted user {userID}", 200


@app.route("/login", methods=["GET"])
def login():

    username = request.args.get("username", None)
    password = request.args.get("password", None)

    if username is None:
        return "username is missing", 422
    if password is None:
        return "email is missing", 422

    user = User.query.filter(User.username == username).first()

    if user is None:
        return f"User cannot be found", 422

    if user.password == encryptPassword(password):

        jsonList = {
            "userID": user.id,
            "username": user.username,
            "email": user.email
        }

        return jsonify(jsonList), 200
    else:
        return "incorrect credentials", 403


@app.route('/dropDatabase', methods=["DELETE"])
def dropDatabase():

    db.drop_all()

    return "dropped database", 200


@app.route("/createDatabase", methods=["POST"])
def createDatabase():

    db.create_all()

    return "created database", 200


@app.route("/books/all", methods=["GET"])
def getAllBooks():

    jsonList = []
    try:
        for book in Book.query.all():
            jsonList.append({
                "isbn": book.isbn,
                "title": book.title,
                "description": book.description,
                "author": book.authorName,
                "googleID": book.googleID,
                "thumbnail": book.thumbnail,
                "totalPages": book.totalPages,
                "publishedDate": book.publishedDate,
                "automaticallyScraped": book.automaticallyScraped
            })
    except Exception as e:
        print(e)
        print("error occurred")
        return "An error has occured", 400

    return jsonify(jsonList), 200

@app.route("/books/<isbn>", methods=["PUT"])
def updateBook(isbn):

    title = request.args.get("title", None)
    author = request.args.get("author", None)
    description = request.args.get("description", None)
    totalPages = request.args.get("totalPages", None)
    publishedDate = request.args.get("publishedDate", None)

    book = Book.query.filter(Book.isbn == isbn).first()
    authorObj = Author.query.filter(Author.authorName == book.authorName).first()

    if book is None:
        return "Book cannot be found", 404

    if book.automaticallyScraped:
        return "Book cannot be edited", 403

    if title is not None:
        book.title = title
    if author is not None:
        book.authorName = author
    if description is not None:
        book.description = description
    if totalPages is not None:
        book.totalPages = totalPages
    if publishedDate is not None:
        book.publishedDate = publishedDate


    book.addBookToAuthor()
    db.session.commit()

    d = AuthorToBook.delete().where(AuthorToBook.c.authorID == authorObj.authorID and AuthorToBook.c.isbn == book.isbn)
    db.session.execute(d)
    db.session.commit()

    return "Updated Book Instance", 200

@app.route("/users/<userID>/bookshelf/all", methods=["GET"])
def getAllUserBookshelves(userID):

    jsonList = []
    try:
        for bookshelf in Bookshelf.query.filter(Bookshelf.userID == userID):

            jsonList.append({
                "bookshelfID": bookshelf.bookshelfID,
                "name": bookshelf.name,
            })
    except Exception as e:
        print(e)
        print("error occurred")

    return jsonify(jsonList), 200


@app.route("/bookshelf/all", methods=["GET"])
def getAllBookshelves():

    jsonList = []
    try:
        for bookshelf in Bookshelf.query.all():

            jsonList.append({
                "bookshelfID": bookshelf.bookshelfID,
                "name": bookshelf.name,
                "userID": bookshelf.userID
            })
    except Exception as e:
        print(e)
        print("error occurred")

    return jsonify(jsonList), 200


@app.route("/users/<userID>/bookshelf/add", methods=["POST"])
def addNewBookshelf(userID):

    bookshelfName = request.args.get("name", None)

    if bookshelfName is None:
        return "Bookshelf name is empty", 422

    newBookshelf = Bookshelf(bookshelfName, userID)
    db.session.add(newBookshelf)
    db.session.commit()

    return "added new bookshelf", 201


@app.route("/users/<userID>/bookshelf/<bookshelfID>/rename", methods=["PUT"])
def renameBookshelf(userID, bookshelfID):

    newName = request.args.get("name", None)
    bookshelfID = int(bookshelfID)
    userID = int(userID)

    bookshelf = Bookshelf.query.filter(Bookshelf.bookshelfID == bookshelfID).first()

    if bookshelf.userID != userID:
        return "Bookshelf does not belong to that user", 403

    bookshelf.name = newName
    db.session.commit()

    return "renamed bookshelf", 200


@app.route("/users/<userID>/bookshelf/<bookshelfID>/delete", methods=["DELETE"])
def deleteBookshelf(userID, bookshelfID):

    newName = request.args.get("name", None)
    bookshelfID = int(bookshelfID)
    userID = int(userID)

    bookshelf = Bookshelf.query.filter(Bookshelf.bookshelfID == bookshelfID).first()

    if bookshelf.userID != userID:
        return "Bookshelf does not belong to that user", 403


    for bookInstance in BookInstance.query.filter(BookInstance.bookshelfID == bookshelfID):
        bookInstance.bookshelfID = None

    Bookshelf.query.filter(Bookshelf.bookshelfID == bookshelfID).delete()

    db.session.commit()

    return "deleted bookshelf", 200


@app.route("/users/<userID>/bookshelf/<bookshelfID>", methods=["GET"])
def getBooksFromBookshelf(userID, bookshelfID):

    JsonList = []

    bookshelf = Bookshelf.query.filter(Bookshelf.bookshelfID == bookshelfID).first()

    if bookshelf is None:
        return "Bookshelf does not exist", 422
    if bookshelf.userID != int(userID):
        return "Bookshelf does not belong to that user", 403
    bookInstance = BookInstance.query.filter(BookInstance.bookshelfID == bookshelfID).first()
    if bookInstance is None:
        return "Bookshelf is empty", 200

    for index, instance in enumerate(BookInstance.query.filter(BookInstance.bookshelfID == bookshelfID)):

        JsonList.append({"userData": {},
                         "bookData": {}})

        JsonList[index]["userData"] = {
            "isbn": instance.isbn,
            "bookInstanceID": instance.bookInstanceID,
            "currentPage": instance.currentPage,
            "completed": instance.completed,
            "userID": instance.userID,
            "bookshelfID": instance.bookshelfID,
            "rating": instance.rating,
            "totalTimeRead": instance.totalTimeRead
        }

        for book in Book.query.filter(Book.isbn == instance.isbn):
            JsonList[index]["bookData"] = {
                "isbn": book.isbn,
                "title": book.title,
                "description": book.description,
                "author": book.authorName,
                "googleID": book.googleID,
                "thumbnail": book.thumbnail,
                "totalPages": book.totalPages,
                "publishedDate": book.publishedDate,
                "automaticallyScraped": book.automaticallyScraped
            }

    return jsonify(JsonList), 200


@app.route("/users/<userID>/bookshelf/<bookshelfID>/add", methods=["POST"])
def addBookToBookshelf(userID, bookshelfID):

    bookInstanceID = request.args.get("bookInstanceID")

    bookInstance = BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).first()
    bookshelf = Bookshelf.query.filter(Bookshelf.bookshelfID == bookshelfID).first()

    if bookInstance is None:
        return "Book Instance not found", 404
    if bookshelf is None:
        return "Bookshelf not found", 404

    # checks to see if bookshelf belongs to that user
    if bookInstance.userID == bookshelf.userID:
        bookInstance.bookshelfID = bookshelfID
        db.session.commit()
        return f"added book {bookInstanceID} to bookshelf {bookshelfID}", 200
    else:
        print("Book Instance userID and Bookshelf UserID do not match")
        return f"That book does not belong to owner of bookshelf", 403


@app.route("/authors/all", methods=["GET"])
def getAllAuthors():

    JsonList = []

    for index, author in enumerate(Author.query.all()):
        print(author.authorName)
        JsonList.append({
            "authorData": {},
            "books": []
        })

        JsonList[index]["authorData"] = {
            "authorID": author.authorID,
            "authorName": author.authorName,
        }

        for book in author.books:
            JsonList[index]["books"].append({
                "isbn": book.isbn,
                "title": book.title,
                "description": book.description,
                "author": book.authorName,
                "googleID": book.googleID
            })

    return jsonify(JsonList), 200


@app.route("/authors/<authorID>", methods=["GET"])
def getSpecificAuthor(authorID):

    author = Author.query.filter(Author.authorID == authorID).first()

    if author is None:
        return "Author does not exist", 422

    JsonList = [{
        "authorData": {},
        "books": []
    }]

    JsonList[0]["authorData"] = {
        "authorID": author.authorID,
        "authorName": author.authorName,
    }

    for book in author.books:
        JsonList[0]["books"].append({
            "isbn": book.isbn,
            "title": book.title,
            "description": book.description,
            "author": book.authorName,
            "googleID": book.googleID
        })

    return jsonify(JsonList), 200

@app.route("/getThumbnail", methods=["GET"])
def getThumbnail():

    try:
        path = request.args.get("path", None)
        return send_file(path, mimetype="image/gif"), 200

    except:
        return "Error finding file", 404


@app.route("/books/scrape", methods=["POST"])
def scrapeBook():
    """
    checks to see if book data already exists, scrapes data if it does not
    :return:
    """

    isbn = request.args.get("isbn", None)

    if isbn is None:
        return "isbn parameter is missing", 400

    book = Book.query.filter(Book.isbn == isbn).first()

    # book does not exist in database
    if book is None:
        book = Book(isbn=isbn)
        db.session.add(book)
        db.session.commit()

    # book not correctly scraped
    if book.title == "":
        Book.query.filter(Book.isbn == isbn).delete()
        db.session.commit()

        return "Cannot be found", 404

    return jsonify({
        "isbn": book.isbn,
        "title": book.title,
        "description": book.description,
        "author": book.authorName,
        "googleID": book.googleID,
        "thumbnail": book.thumbnail,
        "totalPages": book.totalPages,
        "publishedDate": book.publishedDate
    }), 200



















