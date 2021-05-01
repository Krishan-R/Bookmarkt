from exts import db


class User(db.Model):
    """A User class which stores relevant information about users"""

    __tablename__ = "User"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(15), nullable=False, unique=True)
    email = db.Column(db.String(50), nullable=False, unique=True)
    password = db.Column(db.String(64), nullable=False)

    def __init__(self, username="", email="", password=""):
        """
        :param username: username of the user
        :param email: email address of the user
        :param password: hashed password of the user
        """

        self.username = username
        self.email = email,
        self.password = password

    def __repr__(self):
        return '<User %r>' % self.username

    def toJson(self):
        return {
            "userID": self.id,
            "username": self.username,
            "email": self.email
        }
