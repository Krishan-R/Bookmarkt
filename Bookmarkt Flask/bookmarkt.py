import flask
from flask import request, jsonify
from user import User
from bookshelf import Bookshelf
from book import Book
from flask_sqlalchemy import SQLAlchemy
import os

app = flask.Flask(__name__)
app.config["DEBUG"] = True

file_path = os.path.abspath(os.getcwd())+"\database.db"
app.config["SQLALCHEMY_DATABASE_URI"] = 'sqlite:///'+file_path
db = SQLAlchemy(app)

@app.route('/', methods=["GET"])
def home():

    db.create_all()

    admin = User(username="admin", email="aksnasl")
    guest = User(username="guest", email="nnnnnf")

    db.session.add(admin)
    db.session.add(guest)
    db.session.commit()

    print(User.query.all())

    return "<h1>Home</h1>"

@app.route('/Users', methods=["GET"])
def users():

    jsonList = []

    for user in User.query.all():
        jsonList.append({
            "id": user.id,
            "username": user.username,
            "email": user.email
        })

    return jsonify(jsonList)

@app.route('/Users/dropTable', methods=["GET"])
def dropDatabase():

    db.drop_all()

    return "dropped table"


@app.route("/api/v1/resources/books/all", methods=["GET"])
def api_all():
    harryPotter = Book(isbn="9781408855652")

    return jsonify(harryPotter.getData())

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(15), nullable=False)
    email = db.Column(db.String(50), nullable=False)

    def __repr__(self):

        return '<User %r>' % self.username






















