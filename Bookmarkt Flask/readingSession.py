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
        """
        :param bookInstanceID: reading session's bookInstanceID
        :param pagesRead: number of pages read in session
        :param timeRead: minutes spent reading in session
        :param userID: userID
        :param date: Date of reading session
        """

        self.bookInstanceID = bookInstanceID
        self.pagesRead = pagesRead
        self.timeRead = timeRead
        self.userID = userID
        self.date = date

    def __repr__(self):
        return "<ReadingSession> %r" % self.readingSessionID

    def toJson(self):
        """Returns a Json containing relevant details"""

        sessionJson = {
            "readingSessionID": self.readingSessionID,
            "bookInstanceID": self.bookInstanceID,
            "userID": self.userID,
            "pagesRead": self.pagesRead,
            "timeRead": self.timeRead,
            "date": self.date.strftime("%Y-%m-%d"),
        }

        return sessionJson
