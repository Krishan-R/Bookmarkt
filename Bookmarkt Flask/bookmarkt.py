import flask
from flask import request, jsonify
from book import Book

app = flask.Flask(__name__)
app.config["DEBUG"] = True


@app.route('/', methods=["GET"])
def home():
    return "<h1>Home</h1>"


@app.route("/api/v1/resources/books/all", methods=["GET"])
def api_all():
    colourOfMagic = Book("0552171891")

    return jsonify(colourOfMagic.getData())

# app.run()
