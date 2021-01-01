import flask
from flask import request, jsonify
from user import User
from bookshelf import Bookshelf
from author import Author
from book import Book
from bookInstance import BookInstance
from authorToBook import AuthorToBook

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

    return jsonify(jsonList)


@app.route('/users/<userID>', methods=["GET"])
def getSpecificUser(userID):

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

    return jsonify(jsonList)


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

    return jsonify(JsonList)


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

    return jsonify(JsonList)


@app.route("/users/<userID>/books/add", methods=["GET", "POST"])
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
    else:
        currentPage = 0

    if completed is None or completed.lower() == "false":
        completed = False
    elif completed.lower() == "true":
        completed = True

    if bookshelfID is not None:
        try:
            bookshelfID = int(bookshelfID)
        except Exception as e:
            print(e)
            print("An Error has occurred")

    newBookInstance = BookInstance(isbn, userID, completed=completed, currentPage=currentPage, bookshelfID=bookshelfID)
    db.session.add(newBookInstance)
    db.session.commit()

    # check to see if book data is in database
    if Book.query.filter(Book.isbn == isbn).count() == 0:
        print("book not found, trying to scrape")
        newBook = Book(isbn=isbn)
        db.session.add(newBook)
        db.session.commit()

    return "added new BookInstance"


@app.route('/users/<userID>/books/<bookInstanceID>/edit', methods=["GET", "PUT"])
def updateBookInstance(userID, bookInstanceID):

    currentPage = request.args.get("currentPage", None)
    completed = request.args.get("completed", None)
    bookshelfID = request.args.get("bookshelfID", None)
    bookInstance = BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).first()

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
            bookInstance.bookshelfID = bookshelfID
        except Exception as e:
            print(e)
            print("An Error has occurred")

    db.session.commit()

    return f"Edited book instance {bookInstanceID}"


@app.route("/bookinstance/delete/<bookInstanceID>")
def deleteUserBook(bookInstanceID):

    BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).delete()
    db.session.commit()

    return f"deleted book instance id {bookInstanceID}"


@app.route("/users/<userID>/books/delete/<bookInstanceID>", methods=["GET", "POST"])
def deleteUserBook2(userID, bookInstanceID):
    deleteUserBook(bookInstanceID)

    return f"deleted book instance id {bookInstanceID}"


@app.route("/users/<userID>/books/delete/all", methods=["GET", "POST"])
def deleteAllUserBook(userID):

    BookInstance.query.filter(BookInstance.userID == userID).delete()
    db.session.commit()

    return f"deleted all book instanced from user {userID}"


@app.route('/users/add', methods=["GET", "POST"])
def addNewUser():

    newUsername = request.args.get("username", None)
    email = request.args.get("email", None)

    newUser = User(username=newUsername, email=email)
    db.session.add(newUser)
    db.session.commit()

    return "added new User"


@app.route("/users/<userID>/delete", methods=["GET", "POST"])
def deleteUser(userID):

    User.query.filter(User.id == userID).delete()
    Bookshelf.query.filter(Bookshelf.userID == userID).delete()
    BookInstance.query.filter(BookInstance.userID == userID).delete()

    db.session.commit()

    return f"deleted user {userID}"


@app.route('/dropTable', methods=["GET"])
def dropDatabase():

    db.drop_all()

    return "dropped table"


@app.route("/books/all", methods=["GET"])
def allBooks():

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

    return jsonify(jsonList)


@app.route("/users/<userID>/bookshelf/all", methods=["GET"])
def getAllBookshelves(userID):

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

    return jsonify(jsonList)


@app.route("/users/<userID>/bookshelf/add", methods=["GET", "POST"])
def addNewBookshelf(userID):

    bookshelfName = request.args.get("name", "")

    newBookshelf = Bookshelf(bookshelfName, userID)
    db.session.add(newBookshelf)
    db.session.commit()

    return "added new bookshelf"


@app.route("/users/<userID>/bookshelf/<bookshelfID>", methods=["GET"])
def getBooksFromBookshelf(userID, bookshelfID):

    JsonList = []

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

    return jsonify(JsonList)


@app.route("/users/<userID>/bookshelf/<bookshelfID>/add", methods=["GET", "PUT"])
def addBookToBookshelf(userID, bookshelfID):

    bookInstanceID = request.args.get("bookInstanceID")

    bookInstance = BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).first()
    bookInstance.bookshelfID = bookshelfID
    db.session.commit()

    return f"added book {bookInstanceID} to bookshelf {bookshelfID}"


@app.route("/authors/all", methods=["GET"])
def getAllAuthors():

    JsonList = []

    for index, author in enumerate(Author.query.all()):

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

    return jsonify(JsonList)


@app.route("/authors/<authorID>", methods=["GET"])
def getSpecificAuthor(authorID):

    author = Author.query.filter(Author.authorID == authorID).first()

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

    return jsonify(JsonList)























