import flask
from flask import request, jsonify
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

file_path = os.path.abspath(os.getcwd()) + "\database.db"
app.config["SQLALCHEMY_DATABASE_URI"] = 'sqlite:///'+file_path

db.init_app(app)


@app.route('/', methods=["GET"])
def home():

    dropDatabase()
    db.create_all()

    admin = User(username="admin", email="aksnasl")
    db.session.add(admin)
    db.session.commit()
    print(User.query.all())

    # StephenKing = Author("Stephen King")
    # # StephenKing.books.append(IT)
    # db.session.add(StephenKing)
    # db.session.commit()

    # harryPotter = Book(isbn="9781408855652")
    IT = Book(isbn="9781501142970")
    cujo = Book(isbn="9781444708127")
    institute = Book(isbn="9781529355413")

    db.session.add(IT)
    db.session.add(institute)
    db.session.add(cujo)
    db.session.commit()
    print(Book.query.all())

    adminBookshelf = Bookshelf("adminBookshelf", 1)
    db.session.add(adminBookshelf)
    db.session.commit()
    print(Bookshelf.query.all())

    ITBookInstance = BookInstance("9781501142970", 1, bookshelfID=1)
    db.session.add(ITBookInstance)
    db.session.commit()

    # testReadingSession = ReadingSession(1, 50, 30, 1)
    # db.session.add(testReadingSession)
    # db.session.commit()

    return "<h1>Home</h1>"


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
            "bookshelfID": instance.bookshelfID
        }

        for book in Book.query.filter(Book.isbn == instance.isbn):
            JsonList[index]["bookData"] = {
                "isbn": book.isbn,
                "title": book.title,
                "description": book.description,
                "author": book.authorName,
                "googleID": book.googleID
            }

    return jsonify(JsonList), 200


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
            "bookshelfID": instance.bookshelfID
        }

        for book in Book.query.filter(Book.isbn == instance.isbn):
            JsonList[index]["bookData"] = {
                "isbn": book.isbn,
                "title": book.title,
                "description": book.description,
                "author": book.authorName,
                "googleID": book.googleID
            }

    return jsonify(JsonList), 200


@app.route("/users/<userID>/books/add", methods=["POST"])
def addUserBook(userID):

    isbn = request.args.get("isbn", None)
    currentPage = request.args.get("currentPage", None)
    completed = request.args.get("completed", None)
    bookshelfID = request.args.get("bookshelfID", None)

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

    newBookInstance = BookInstance(isbn, userID, completed=completed, currentPage=currentPage, bookshelfID=bookshelfID)
    db.session.add(newBookInstance)
    db.session.commit()

    # check to see if book data is in database
    if Book.query.filter(Book.isbn == isbn).count() == 0:
        print("book not found, trying to scrape")
        newBook = Book(isbn=isbn)
        db.session.add(newBook)
        db.session.commit()

    return "added new BookInstance", 201


@app.route('/users/<userID>/books/<bookInstanceID>/edit', methods=["PUT"])
def updateBookInstance(userID, bookInstanceID):

    userID = int(userID)

    currentPage = request.args.get("currentPage", None)
    completed = request.args.get("completed", None)
    bookshelfID = request.args.get("bookshelfID", None)
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
        print("BookInstance does not belong to user")
        return f"Book Instance {bookInstanceID} does not belong to user {userID}", 403

    BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).delete()
    db.session.commit()

    return f"deleted book instance id {bookInstanceID}", 200


@app.route("/users/<userID>/books/delete/all", methods=["DELETE"])
def deleteAllUserBook(userID):

    BookInstance.query.filter(BookInstance.userID == userID).delete()
    db.session.commit()

    return f"deleted all book instances from user {userID}", 200


@app.route("/users/<userID>/books/<bookInstanceID>/read", methods=["POST"])
def addReadingSession(userID, bookInstanceID):

    currentPage = request.args.get("currentPage", None)
    timeRead = request.args.get("timeRead", None)
    bookInstance = BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).first()

    if bookInstance.userID != int(userID):
        print(bookInstance.userID, bookInstance.book.title, userID)
        print("Book instance does not belong to user")
        return f"Book Instance {bookInstanceID} does not belong to user {userID}", 403

    if currentPage is None:
        return "currentPage missing", 422
    if timeRead is None:
        return "timeRead missing", 422
    else:

        readingSession = ReadingSession(bookInstanceID, currentPage, timeRead, userID)
        db.session.add(readingSession)

        # changes the current page of the bookinstance object
        bookInstance.currentPage = currentPage

        db.session.commit()

        return "add reading session", 201


@app.route('/users/add', methods=["POST"])
def addNewUser():

    newUsername = request.args.get("username", None)
    email = request.args.get("email", None)

    if newUsername is None:
        return "username is missing", 422
    if email is None:
        return "email is missing", 422

    newUser = User(username=newUsername, email=email)
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


@app.route('/dropTable', methods=["DELETE"])
def dropDatabase():

    db.drop_all()

    return "dropped table"


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
                "googleID": book.googleID
            })
    except Exception as e:
        print(e)
        print("error occurred")
        return "An error has occured", 400

    return jsonify(jsonList), 200


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


@app.route("/users/<userID>/bookshelf/<bookshelfID>", methods=["GET"])
def getBooksFromBookshelf(userID, bookshelfID):

    JsonList = []

    bookshelf = Bookshelf.query.filter(Bookshelf.bookshelfID == bookshelfID).first()

    if bookshelf is None:
        return "Bookshelf does not exist", 422
    if bookshelf.userID != int(userID):
        return "Bookshelf does not belong to that user", 403

    for index, instance in enumerate(BookInstance.query.filter(BookInstance.bookshelfID == bookshelfID)):

        JsonList.append({"userData": {},
                         "bookData": {}})

        JsonList[index]["userData"] = {
            "isbn": instance.isbn,
            "bookInstanceID": instance.bookInstanceID,
            "currentPage": instance.currentPage,
            "completed": instance.completed,
            "userID": instance.userID,
            "bookshelfID": instance.bookshelfID
        }

        for book in Book.query.filter(Book.isbn == instance.isbn):
            JsonList[index]["bookData"] = {
                "isbn": book.isbn,
                "title": book.title,
                "description": book.description,
                "author": book.authorName,
                "googleID": book.googleID
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






















