import flask
from flask import request, jsonify
from user import User
from bookshelf import Bookshelf
from book import Book
import os
from exts import db

app = flask.Flask(__name__)
app.config["DEBUG"] = True

file_path = os.path.abspath(os.getcwd()) + "\database.db"
app.config["SQLALCHEMY_DATABASE_URI"] = 'sqlite:///'+file_path

db.init_app(app)


@app.route('/', methods=["GET"])
def home():

    db.create_all()

    admin = User(username="admin", email="aksnasl")
    guest = User(username="guest", email="nnnnnf")
    db.session.add(admin)
    db.session.add(guest)
    db.session.commit()
    print(User.query.all())

    harryPotter = Book(isbn="9781408855652")
    IT = Book(googleID="S85NCwAAQBAJ")
    db.session.add(harryPotter)
    db.session.add(IT)
    db.session.commit()
    print(Book.query.all())

    guestBookshelf = Bookshelf("guestBookshelf111", 2)
    db.session.add(guestBookshelf)
    db.session.commit()
    print(Bookshelf.query.all())




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


@app.route('/users/add/<newUsername>', methods=["GET", "POST"])
def addNewUser(newUsername):

    newUser = User(username=newUsername, email="empty")
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


























