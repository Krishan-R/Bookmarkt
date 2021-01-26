from exts import db


class ReadingSession(db.Model):
    """Stores information about reading sessions"""

    __tablename__ = "ReadingSession"
    readingSessionID = db.Column(db.Integer, primary_key=True)
    bookInstanceID = db.Column(db.Integer, db.ForeignKey("BookInstance.bookInstanceID"), nullable=False)
    bookInstance = db.relationship("BookInstance", backref=db.backref("BookInstanceReadingSession", lazy=True))
    userID = db.Column(db.Integer, db.ForeignKey("User.id"), nullable=False)
    User = db.relationship("User", backref=db.backref("UserReadingSession", lazy=True))
    currentPage = db.Column(db.Integer)
    timeRead = db.Column(db.Integer)

    def __init__(self, bookInstanceID, currentPage, timeRead, userID):
        self.bookInstanceID = bookInstanceID
        self.currentPage = currentPage
        self.timeRead = timeRead
        self.userID = userID

    def __repr__(self):
        return "<ReadingSession> %r" % self.readingSessionID