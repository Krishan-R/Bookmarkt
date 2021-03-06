from exts import db


class Bookshelf(db.Model):
    """Bookshelf class which stores multiple Book objects"""

    __tablename__ = "Bookshelf"
    bookshelfID = db.Column(db.Integer, unique=True, primary_key=True)
    name = db.Column(db.String(50))
    userID = db.Column(db.Integer, db.ForeignKey("User.id"), nullable=False)
    user = db.relationship("User", backref=db.backref("posts", lazy=True))

    def __init__(self, bookshelfName="", userID=""):
        """
        :param bookshelfName: Name of the bookshelf
        :param userID: Bookshelf's owner userID
        """

        self.name = bookshelfName
        self.bookList = []
        self.userID = userID

    def toJson(self):
        """Returns a Json containing relevant details"""

        return {
            "bookshelfID": self.bookshelfID,
            "name": self.name,
            "userID": self.userID
        }
