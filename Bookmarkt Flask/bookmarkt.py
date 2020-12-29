import flask
from flask import request, jsonify
from user import User
from bookshelf import Bookshelf
from book import Book
from bookInstance import BookInstance
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
    guest = User(username="guest", email="nnnnnf")
    db.session.add(admin)
    db.session.add(guest)
    db.session.commit()
    print(User.query.all())

    # harryPotter = Book(isbn="9781408855652")
    # IT = Book(googleID="S85NCwAAQBAJ")
    # db.session.add(harryPotter)
    # db.session.add(IT)
    # db.session.commit()
    # print(Book.query.all())
    #
    # guestBookshelf = Bookshelf("guestBookshelf111", 2)
    # db.session.add(guestBookshelf)
    # db.session.commit()
    # print(Bookshelf.query.all())
    #
    # testBookInstanceHP = BookInstance("9781408855652", 1)
    # testBookInstanceIT = BookInstance("9781501142970", 1)
    # db.session.add(testBookInstanceHP)
    # # db.session.add(testBookInstanceIT)
    # db.session.commit()
    # print(BookInstance.query.all())

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
            "completed": instance.completed
        }

        for book in Book.query.filter(Book.isbn == instance.isbn):
            JsonList[index]["bookData"] = {
                "isbn": book.isbn,
                "title": book.title,
                "description": book.description,
                "author": book.author,
                "googleID": book.googleID
            }

    return jsonify(JsonList)


@app.route("/users/<userID>/books/add", methods=["GET", "POST"])
def addUserBook(userID):

    isbn = request.args.get("isbn", None)
    currentPage = request.args.get("currentPage", None)
    completed = request.args.get("completed", None)

    if currentPage is not None:
        try:
            currentPage = int(currentPage)
        except Exception as e:
            print(e)
            print("An Error has occurred")
    else:
        currentPage = 0

    if completed.lower() == "false" or completed is None:
        completed = False
    elif completed.lower() == "true":
        completed = True

    newBookInstance = BookInstance(isbn, userID, completed=completed, currentPage=currentPage)
    db.session.add(newBookInstance)
    db.session.commit()

    # check to see if book data is in database
    if Book.query.filter(Book.isbn == isbn).count() == 0 :
        newBook = Book(isbn=isbn)
        db.session.add(newBook)
        db.session.commit()

    return "added new BookInstance"


@app.route("/users/<userID>/books/delete/<bookInstanceID>", methods=["GET", "POST"])
def deleteUserBook(userID, bookInstanceID):

    BookInstance.query.filter(BookInstance.bookInstanceID == bookInstanceID).delete()
    db.session.commit()

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
                "author": book.author,
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


@app.route("/users/<userID>/bookshelf/new/<bookshelfName>", methods=["GET", "POST"])
def addNewBookshelf(userID, bookshelfName):

    newBookshelf = Bookshelf(bookshelfName, userID)
    db.session.add(newBookshelf)
    db.session.commit()

    return "added new bookshelf"


























