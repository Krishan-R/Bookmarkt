from exts import db


class BookInstance(db.Model):
    """BookInstance stores all user specific data about books

    :param isbn: ISBN of book
    :param userID: ID of user"""

    bookInstanceID = db.Column(db.Integer, primary_key=True)
    isbn = db.Column(db.Integer, db.ForeignKey("book.isbn"), nullable=False)
    book = db.relationship("Book", backref=db.backref("book_posts", lazy=True))
    userID = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False)
    user = db.relationship("User", backref=db.backref("user_posts", lazy=True))
    completed = db.Column(db.Boolean, nullable=False)
    currentPage = db.Column(db.Integer, nullable=False)

    def __init__(self, isbn, userID):
        self.isbn = isbn
        self.userID = userID
        self.completed = False
        self.currentPage = 0

    def __repr__(self):
        return "<BookInstance %r>" % self.bookInstanceID
