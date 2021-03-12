from exts import db


class BookInstance(db.Model):
    """BookInstance stores all user specific data about books

    :param isbn: ISBN of book
    :param userID: ID of user"""

    __tablename__ = "BookInstance"
    bookInstanceID = db.Column(db.Integer, primary_key=True)
    isbn = db.Column(db.Integer, db.ForeignKey("Book.isbn"), nullable=False)
    book = db.relationship("Book", backref=db.backref("book_posts", lazy=True))
    userID = db.Column(db.Integer, db.ForeignKey("User.id"), nullable=False)
    user = db.relationship("User", backref=db.backref("user_posts", lazy=True))
    bookshelfID = db.Column(db.Integer, db.ForeignKey("Bookshelf.bookshelfID"))
    bookshelf = db.relationship("Bookshelf", backref=db.backref("bookshelf_posts", lazy=True))
    goalDate = db.Column(db.Date)
    completed = db.Column(db.Boolean, nullable=False)
    dateCompleted = db.Column(db.Date)
    currentPage = db.Column(db.Integer, nullable=False)
    rating = db.Column(db.Integer)
    totalTimeRead = db.Column(db.Integer)
    borrowingFrom = db.Column(db.String(50))
    borrowingTo = db.Column(db.String(50))
    borrowingTime = db.Column(db.Date)

    def __init__(self, isbn, userID, currentPage=0, completed=False, bookshelfID=None, rating=0, totalTimeRead=0):
        self.isbn = isbn
        self.userID = userID
        self.completed = completed
        self.currentPage = currentPage
        self.bookshelfID = bookshelfID
        self.rating = rating
        self.totalTimeRead = totalTimeRead

    def toJson(self):

        self.returnGoalDate = None
        self.returnDateCompleted = None
        self.returnBorrowingTime = None

        if self.goalDate is not None:
            self.returnGoalDate = self.goalDate.strftime("%Y-%m-%d")

        if self.dateCompleted is not None:
            self.returnDateCompleted = self.dateCompleted.strftime("%Y-%m-%d")

        if self.returnBorrowingTime is not None:
            self.returnBorrowingTime = self.returnBorrowingTime.strftime("%Y-%m-%d")

        return {
            "isbn": self.isbn,
            "bookInstanceID": self.bookInstanceID,
            "currentPage": self.currentPage,
            "completed": self.completed,
            "userID": self.userID,
            "bookshelfID": self.bookshelfID,
            "rating": self.rating,
            "totalTimeRead": self.totalTimeRead,
            "goalDate": self.returnGoalDate,
            "dateCompleted": self.returnDateCompleted,
            "borrowingFrom": self.borrowingFrom,
            "borrowingTo": self.borrowingTo,
            "borrowingTime": self.returnBorrowingTime
        }

    def __repr__(self):
        return "<BookInstance %r>" % self.bookInstanceID
