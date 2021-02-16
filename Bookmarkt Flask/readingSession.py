from exts import db
import datetime


class ReadingSession(db.Model):
    """Stores information about reading sessions"""

    __tablename__ = "ReadingSession"
    readingSessionID = db.Column(db.Integer, primary_key=True)
    bookInstanceID = db.Column(db.Integer, db.ForeignKey("BookInstance.bookInstanceID"), nullable=False)
    bookInstance = db.relationship("BookInstance", backref=db.backref("BookInstanceReadingSession", lazy=True))
    userID = db.Column(db.Integer, db.ForeignKey("User.id"), nullable=False)
    User = db.relationship("User", backref=db.backref("UserReadingSession", lazy=True))
    pagesRead = db.Column(db.Integer)
    timeRead = db.Column(db.Integer)
    date = db.Column(db.Date)

    def __init__(self, bookInstanceID, pagesRead, timeRead, userID, date=datetime.date.today()):
        self.bookInstanceID = bookInstanceID
        self.pagesRead = pagesRead
        self.timeRead = timeRead
        self.userID = userID
        self.date = date

    def __repr__(self):
        return "<ReadingSession> %r" % self.readingSessionID