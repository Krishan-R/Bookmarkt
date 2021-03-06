import datetime

from pathlib import Path
import flask
from flask import request, jsonify, send_file
import hashlib
from user import User
from bookshelf import Bookshelf
from book import Book
from bookInstance import BookInstance
from readingSession import ReadingSession

import os
from exts import db

app = flask.Flask(__name__)
app.config["DEBUG"] = True

if Path("/database").is_dir():
    file_path = "/database/database.db"
    app.config["SQLALCHEMY_DATABASE_URI"] = 'sqlite:///' + file_path

else:
    file_path = os.path.abspath(os.getcwd()) + "/database/database.db"

print(f"database path is {file_path}")
app.config["SQLALCHEMY_DATABASE_URI"] = 'sqlite:///' + file_path

db.init_app(app)

with app.app_context():
    try:
        if len(os.listdir(file_path.replace("/database.db", ""))) != 1:
            print("cant find database file")
            db.drop_all()
            db.create_all()
            print("created database")
    except FileNotFoundError:
        print("database not found, creating")
        os.mkdir(file_path.replace("/database.db", ""))
        db.drop_all()
        db.create_all()
    except NotADirectoryError:
        os.mkdir(file_path.replace("/database.db", ""))
        db.drop_all()
        db.create_all()


def encryptPassword(password):
    return hashlib.sha256(password.encode("utf-8")).hexdigest()


@app.route('/', methods=["GET"])
def home():
    return "True", 200


@app.route('/users/<userID>', methods=["GET"])
def getUser(userID):

    user = User.query.filter(User.id == userID).first()

    if user is None:
        return "User does not exist", 404

    return user.toJson(), 200


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

    return newUser.toJson(), 201


@app.route("/users/<userID>/delete", methods=["DELETE"])
def deleteUser(userID):
    User.query.filter(User.id == userID).delete()
    Bookshelf.query.filter(Bookshelf.userID == userID).delete()
    BookInstance.query.filter(BookInstance.userID == userID).delete()
    ReadingSession.query.filter(BookInstance.userID == userID).delete()

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
        return f"User cannot be found", 404

    if user.password == encryptPassword(password):
        return user.toJson(), 200
    else:
        return "incorrect credentials", 403


@app.route('/users/<userID>/books/all', methods=["GET"])
def getAllUserBooks(userID):
    JsonList = []

    for index, instance in enumerate(BookInstance.query.filter(BookInstance.userID == userID)):

        JsonList.append({"userData": {},
                         "bookData": {}})

        JsonList[index]["userData"] = instance.toJson()

        for book in Book.query.filter(Book.isbn == instance.isbn):
            JsonList[index]["bookData"] = book.toJson()

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
        "userData": bookInstance.toJson(),
        "bookData": book.toJson()
    }

    return jsonify(json), 200


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
    totalPages = request.args.get("totalPages", None)
    dateCompleted = request.args.get("dateCompleted", None)
    borrowingTime = request.args.get("borrowingTime", None)
    borrowingFrom = request.args.get("borrowingFrom", None)
    borrowingTo = request.args.get("borrowingTo", None)
    goalDate = request.args.get("goalDate", None)

    if currentPage is not None:
        try:
            currentPage = int(currentPage)
        except Exception as e:
            print(e)
            return "currentPage value not valid", 422
    else:
        currentPage = 0

    if completed is None or completed.lower() == "false":
        completed = False
    elif completed.lower() == "true":
        completed = True

    if dateCompleted is not None:
        try:
            dateCompleted = datetime.datetime.strptime(dateCompleted, "%Y-%m-%d")
        except:
            dateCompleted = dateCompleted

    if borrowingTime is not None:
        borrowingTime = datetime.datetime.strptime(borrowingTime, "%Y-%m-%d")

    if goalDate is not None:
        goalDate = datetime.datetime.strptime(goalDate, "%Y-%m-%d")

    if bookshelfID is not None:
        try:
            bookshelfID = int(bookshelfID)

            # checks to see if bookshelf exists and belongs to that user
            bookshelf = Bookshelf.query.filter(Bookshelf.bookshelfID == bookshelfID).first()
            if bookshelf is None:
                return "Bookshelf does not not exist", 404

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
        print(newBook.totalPages)
        db.session.add(newBook)
        db.session.commit()

    # sets total pages for book instance if not in request
    if totalPages is None:
        totalPages = book.totalPages

    newBookInstance = BookInstance(isbn, userID, completed=completed, currentPage=currentPage, totalPages=totalPages,
                                   bookshelfID=bookshelfID, rating=rating, totalTimeRead=totalTimeRead,
                                   dateCompleted=dateCompleted, borrowingFrom=borrowingFrom, borrowingTo=borrowingTo,
                                   borrowingTime=borrowingTime,
                                   goalDate=goalDate)
    db.session.add(newBookInstance)
    db.session.commit()

    return newBookInstance.toJson(), 201


@app.route('/users/<userID>/books/<bookInstanceID>/edit', methods=["PUT"])
def updateBookInstance(userID, bookInstanceID):
    userID = int(userID)

    currentPage = request.args.get("currentPage", None)
    totalPages = request.args.get("totalPages", None)
    completed = request.args.get("completed", None)
    bookshelfID = request.args.get("bookshelfID", None)
    rating = request.args.get("rating", None)
    totalTimeRead = request.args.get("totalTimeRead", None)
    goalDate = request.args.get("goalDate", None)
    dateCompleted = request.args.get("dateCompleted", datetime.date.today())
    borrowingTime = request.args.get("borrowingTime", None)
    borrowingFrom = request.args.get("borrowingFrom", None)
    borrowingTo = request.args.get("borrowingTo", None)

    bookInstance = BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).first()

    if bookInstance is None:
        return "Book Instance does not exist", 404

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

    if totalPages is not None:
        bookInstance.totalPages = totalPages

    if completed is not None and completed.lower() == "false":
        completed = False
        bookInstance.completed = completed
    elif completed is not None and completed.lower() == "true":
        completed = True

        try:
            dateObj = datetime.datetime.strptime(dateCompleted, "%Y-%m-%d")
        except TypeError:
            dateObj = dateCompleted

        bookInstance.dateCompleted = dateObj
        bookInstance.completed = completed

    if goalDate is not None:

        if goalDate == "null":
            dateObj = None
        else:
            dateObj = datetime.datetime.strptime(goalDate, "%Y-%m-%d")
        bookInstance.goalDate = dateObj

    if borrowingTime is not None:

        if borrowingTime == "null":
            dateObj = None
        else:
            dateObj = datetime.datetime.strptime(borrowingTime, "%Y-%m-%d")
        bookInstance.borrowingTime = dateObj

    if borrowingFrom is not None:
        if borrowingFrom == "null":
            bookInstance.borrowingFrom = None
        else:
            bookInstance.borrowingFrom = borrowingFrom

    if borrowingTo is not None:
        if borrowingTo == "null":
            bookInstance.borrowingTo = None
        else:
            bookInstance.borrowingTo = borrowingTo

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

        if bookshelfID == "null":
            bookInstance.bookshelfID = None
        else:

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

    return bookInstance.toJson(), 200


@app.route("/users/<userID>/books/<bookInstanceID>/delete", methods=["DELETE"])
def deleteBookInstance(userID, bookInstanceID):

    bookInstance = BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).first()

    if bookInstance is None:
        return "Book Instance not found", 404

    # checks to see if book instance belongs to that user
    if bookInstance.userID != int(userID):
        return f"Book Instance {bookInstanceID} does not belong to user {userID}", 403

    BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).delete()

    # deletes relevant rows in ReadingSession table
    ReadingSession.query.filter(ReadingSession.bookInstanceID == bookInstanceID).delete()

    db.session.commit()

    return f"deleted book instance", 200


@app.route("/users/<userID>/books/<bookInstanceID>/read", methods=["POST"])
def addReadingSession(userID, bookInstanceID):
    pagesRead = request.args.get("pagesRead", None)
    timeRead = request.args.get("timeRead", None)
    date = request.args.get("date", datetime.date.today())
    updateProgress = request.args.get("updateProgress", True)
    completed = request.args.get("completed", False)

    bookInstance = BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).first()
    book = Book.query.filter(Book.isbn == bookInstance.isbn).first()

    try:
        dateObj = datetime.datetime.strptime(date, "%Y-%m-%d")
    except TypeError:
        dateObj = date

    if bookInstance.userID != int(userID):
        print(bookInstance.userID, bookInstance.book.title, userID)
        print("Book instance does not belong to user")
        return f"Book Instance {bookInstanceID} does not belong to user {userID}", 403

    if bookInstance is None:
        return "Book Instance does not exist", 404

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

        if completed:
            bookInstance.currentPage = bookInstance.totalPages
            bookInstance.dateCompleted = datetime.datetime.today()
            bookInstance.completed = True
        else:
            bookInstance.currentPage += pagesRead

    db.session.commit()

    return readingSession.toJson(), 201


@app.route("/users/<userID>/bookshelf/all", methods=["GET"])
def getAllUserBookshelves(userID):
    jsonList = []
    try:
        for bookshelf in Bookshelf.query.filter(Bookshelf.userID == userID):

            count = len(BookInstance.query.filter(BookInstance.bookshelfID == bookshelf.bookshelfID).all())

            jsonList.append({
                "bookshelfID": bookshelf.bookshelfID,
                "name": bookshelf.name,
                "bookCount": count
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

    newBookshelf = Bookshelf(bookshelfName=bookshelfName, userID=userID)
    db.session.add(newBookshelf)
    db.session.commit()

    return newBookshelf.toJson(), 201


@app.route("/users/<userID>/bookshelf/<bookshelfID>/rename", methods=["PUT"])
def renameBookshelf(userID, bookshelfID):
    newName = request.args.get("name", None)
    bookshelfID = int(bookshelfID)
    userID = int(userID)

    bookshelf = Bookshelf.query.filter(Bookshelf.bookshelfID == bookshelfID).first()

    if bookshelf is None:
        return "Bookshelf does not exist", 404

    if bookshelf.userID != userID:
        return "Bookshelf does not belong to that user", 403

    bookshelf.name = newName
    db.session.commit()

    return bookshelf.toJson(), 200


@app.route("/users/<userID>/bookshelf/<bookshelfID>/delete", methods=["DELETE"])
def deleteBookshelf(userID, bookshelfID):
    bookshelfID = int(bookshelfID)
    userID = int(userID)

    bookshelf = Bookshelf.query.filter(Bookshelf.bookshelfID == bookshelfID).first()

    if bookshelf is None:
        return "Bookshelf does not exist", 404

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

        JsonList[index]["userData"] = instance.toJson()

        for book in Book.query.filter(Book.isbn == instance.isbn):
            JsonList[index]["bookData"] = book.toJson()

    returnJson = {
        "bookshelfID": bookshelfID,
        "name": bookshelf.name,
        "books": JsonList
    }

    return returnJson, 200


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
        return bookInstance.toJson(), 200
    else:
        print("Book Instance userID and Bookshelf UserID do not match")
        return f"That book does not belong to owner of bookshelf", 403


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
    selfLink = request.args.get("selfLink", None)

    if selfLink is not None:
        scrapedBook = Book(selfLink=selfLink)

        print(scrapedBook.toJson())

        return scrapedBook.toJson(), 200

    elif isbn is not None:
        book = Book.query.filter(Book.isbn == isbn).first()

        # book does not exist in database
        if book is None:
            book = Book(isbn=isbn)
            db.session.add(book)
            db.session.commit()

        # book not correctly scraped
        if book.title == "" or book.title is None:
            Book.query.filter(Book.isbn == isbn).delete()
            db.session.commit()

            return "Cannot be found", 404

        return book.toJson(), 200
    else:
        return "error", 400


@app.route("/users/<userID>/books/<bookInstanceID>/stats", methods=["GET"])
def getBookInstanceStats(userID, bookInstanceID):
    userID = int(userID)
    bookInstanceID = int(bookInstanceID)

    time = request.args.get("time", 30)

    time = int(time)

    bookInstance = BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).first()

    if bookInstance is None:
        return "Book Instance cannot be found", 404

    if bookInstance.userID != userID:
        return "Book Instance does not belong to that user", 403

    returnJson = {
        "totalTimeRead": 0,
        "totalPagesRead": 0,
        "statistics": {
            "time": [],
            "pages": []
        }
    }

    start_date = (datetime.datetime.now() - datetime.timedelta(days=time)).date()
    end_date = datetime.date.today()
    delta = datetime.timedelta(days=1)
    while start_date <= end_date:

        time = 0
        pages = 0
        for record in ReadingSession.query \
                .filter(ReadingSession.bookInstanceID == bookInstanceID) \
                .filter(ReadingSession.date == start_date) \
                .all():
            time += record.timeRead
            pages += record.pagesRead
            returnJson["totalTimeRead"] += record.timeRead
            returnJson["totalPagesRead"] += record.pagesRead

        returnJson["statistics"]["time"].append({"date": start_date.strftime("%Y-%m-%d"), "time": time})
        returnJson["statistics"]["pages"].append({"date": start_date.strftime("%Y-%m-%d"), "pages": pages})

        start_date += delta

    return returnJson, 200


@app.route("/users/<userID>/stats", methods=["GET"])
def getReadingStats(userID):
    userID = int(userID)

    requestTime = request.args.get("time", 30)
    requestTime = int(requestTime)
    returnJson = {
        "totalTimeRead": 0,
        "totalPagesRead": 0,
        "statistics": {
            "time": [],
            "pages": []
        }
    }

    start_date = (datetime.datetime.now() - datetime.timedelta(days=requestTime)).date()
    end_date = datetime.date.today()
    delta = datetime.timedelta(days=1)

    while start_date <= end_date:
        time = 0
        pages = 0
        for record in ReadingSession.query \
                .filter(ReadingSession.userID == userID) \
                .filter(ReadingSession.date == start_date) \
                .all():
            time += record.timeRead
            pages += record.pagesRead
            returnJson["totalTimeRead"] += record.timeRead
            returnJson["totalPagesRead"] += record.pagesRead

        returnJson["statistics"]["time"].append({"date": start_date.strftime("%Y-%m-%d"), "time": time})
        returnJson["statistics"]["pages"].append({"date": start_date.strftime("%Y-%m-%d"), "pages": pages})

        start_date += delta

    return returnJson, 200


@app.route("/users/<userID>/stats/weekly", methods=["GET"])
def getUserWeeklyStats(userID):
    userID = int(userID)

    time = request.args.get("time", 30)

    time = int(time)

    start_date = (datetime.datetime.now() - datetime.timedelta(days=time)).date()

    returnJson = {
        "userID": userID,
        "stats": [
            {
                "day": 1,
                "time": 0,
                "pages": 0
            },
            {
                "day": 2,
                "time": 0,
                "pages": 0
            },
            {
                "day": 3,
                "time": 0,
                "pages": 0
            },
            {
                "day": 4,
                "time": 0,
                "pages": 0
            },
            {
                "day": 5,
                "time": 0,
                "pages": 0
            },
            {
                "day": 6,
                "time": 0,
                "pages": 0
            },
            {
                "day": 7,
                "time": 0,
                "pages": 0
            },

        ]
    }

    for session in ReadingSession.query.filter(ReadingSession.userID == userID) \
            .filter(ReadingSession.date > start_date) \
            .all():
        returnJson["stats"][session.date.weekday()]["time"] += session.timeRead
        returnJson["stats"][session.date.weekday()]["pages"] += session.pagesRead

    return returnJson, 200


@app.route("/users/<userID>/recent", methods=["GET"])
def getUserRecent(userID):
    userID = int(userID)

    returnJson = []

    last5Books = []
    index = 0

    for session in ReadingSession.query.filter(ReadingSession.userID == userID).order_by(ReadingSession.date.desc()):

        if session.bookInstanceID not in last5Books:
            instance = BookInstance.query.filter(BookInstance.bookInstanceID == session.bookInstanceID).first()
            book = Book.query.filter(Book.isbn == instance.isbn).first()

            if not instance.completed:

                returnJson.append({
                    "index": index + 1,
                    "data": {
                        "bookData": book.toJson(),
                        "userData": instance.toJson()
                    }
                })

                last5Books.append(session.bookInstanceID)
                index += 1

        if len(last5Books) == 5:
            break

    return jsonify(returnJson), 200


@app.route("/users/<userID>/unread", methods=["GET"])
def getUserUnread(userID):

    userID = int(userID)
    allInstances = BookInstance.query.filter(BookInstance.userID == userID).all()
    readIndex = []

    returnJson = {
        "books": []
    }

    for index, instance in enumerate(allInstances):
        for session in ReadingSession.query.filter(ReadingSession.userID == userID).all():
            if instance.bookInstanceID == session.bookInstanceID or instance.completed:
                readIndex.append(index)

    for index, instance in enumerate(allInstances):
        if index not in readIndex:
            returnJson["books"].append({
                "bookData": instance.book.toJson(),
                "userData": instance.toJson()
            })

    return returnJson, 200


@app.route("/users/<userID>/books/<bookInstanceID>/sessions", methods=["GET"])
def getBookInstanceSessions(userID, bookInstanceID):
    userID = int(userID)
    bookInstanceID = int(bookInstanceID)

    returnJson = {
        "bookInstanceID": bookInstanceID,
        "sessions": []
    }

    for session in ReadingSession.query.filter(ReadingSession.bookInstanceID == bookInstanceID).order_by(
            ReadingSession.date.desc()):
        returnJson["sessions"].append(session.toJson())

    return returnJson, 200


@app.route("/users/<userID>/readingSessions/all", methods=["GET"])
def getAllUserReadingSessions(userID):
    userID = int(userID)

    returnJson = {
        "userID": userID,
        "sessions": []
    }

    for session in ReadingSession.query.filter(ReadingSession.userID == userID).order_by(ReadingSession.date.desc()):
        returnJson["sessions"].append(session.toJson())

    return returnJson, 200


@app.route("/users/<userID>/readingSessions/edit", methods=["PUT"])
def editReadingSession(userID):
    userID = int(userID)

    readingSessionID = request.args.get("readingSessionID", None)
    pagesRead = request.args.get("pagesRead", None)
    timeRead = request.args.get("timeRead", None)
    date = request.args.get("date", None)

    timeRead = int(timeRead)
    pagesRead = int(pagesRead)

    if readingSessionID is None:
        return "Please give readingSessionID", 400

    readingSession = ReadingSession.query.filter(ReadingSession.readingSessionID == readingSessionID).first()
    instance = BookInstance.query.filter(BookInstance.bookInstanceID == readingSession.bookInstanceID).first()

    if readingSession is None:
        return "Cannot find reading session", 404

    if readingSession.userID != userID:
        return "Reading session does not belong to that user", 403

    if pagesRead is not None:
        instance.currentPage -= readingSession.pagesRead - pagesRead
        if instance.currentPage < 0:
            instance.currentPage = 0

        readingSession.pagesRead = pagesRead

    if timeRead is not None:
        instance.totalTimeRead += timeRead - readingSession.timeRead
        if instance.totalTimeRead < 0:
            instance.totalTimeRead = 0

        readingSession.timeRead = timeRead
    if date is not None:
        dateObj = datetime.datetime.strptime(date, "%Y-%m-%d")
        readingSession.date = dateObj

    db.session.commit()

    return readingSession.toJson(), 200


@app.route("/users/<userID>/readingSessions/delete", methods=["DELETE"])
def deleteReadingSession(userID):
    userID = int(userID)

    readingSessionID = request.args.get("readingSessionID", None)

    session = ReadingSession.query.filter(ReadingSession.readingSessionID == readingSessionID).first()
    instance = BookInstance.query.filter(BookInstance.bookInstanceID == session.bookInstanceID).first()

    if session is None:
        return "Cannot find reading session", 404

    if session.userID != userID:
        return "Reading session does not belong to that user", 403

    instance.totalTimeRead -= session.timeRead
    instance.currentPage -= session.pagesRead

    if instance.totalTimeRead < 0:
        instance.totalTimeRead = 0

    if instance.currentPage < 0:
        instance.currentPage = 0

    ReadingSession.query.filter(ReadingSession.readingSessionID == readingSessionID).delete()

    db.session.commit()

    return "Deleted reading session", 200
