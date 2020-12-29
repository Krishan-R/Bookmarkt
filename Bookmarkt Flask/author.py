from exts import db
from authorToBook import AuthorToBook


class Author(db.Model):
    """Author class to store information about book authors

    :param authorName: Name of the author"""

    __tablename__ = "Author"
    authorID = db.Column(db.Integer, primary_key=True)
    authorName = db.Column(db.String(50), nullable=False)
    books = db.relationship("Book", secondary=AuthorToBook)

    def __init__(self, authorName):
        self.authorName = authorName

    def __repr__(self):
        return "<Author %r>" % self.authorName


