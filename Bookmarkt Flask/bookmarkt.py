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
    harryPotter = Book(isbn="9781408855652")



    return jsonify(harryPotter.getData())

# app.run()
