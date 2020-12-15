import flask
from flask import request, jsonify
from bookshelf import Bookshelf
from book import Book

app = flask.Flask(__name__)
app.config["DEBUG"] = True


@app.route('/', methods=["GET"])
def home():
    return "<h1>Home</h1>"


@app.route("/api/v1/resources/books/all", methods=["GET"])
def api_all():
    book1 = Book("0552171891")
    book2 = Book("9781473666948")
    book3 = Book("9781408855652")

    bookshelf = Bookshelf("test")

    bookshelf.addBook(book1)
    bookshelf.addBook(book2)
    bookshelf.addBook(book3)

    bookshelf.getBooks()



    return jsonify(book1.getData())

# app.run()
