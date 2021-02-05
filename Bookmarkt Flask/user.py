from exts import db


class User(db.Model):

    __tablename__ = "User"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(15), nullable=False, unique=True)
    email = db.Column(db.String(50), nullable=False, unique=True)
    password = db.Column(db.String(64), nullable=False)

    def __repr__(self):

        return '<User %r>' % self.username

