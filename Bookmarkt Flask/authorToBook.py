from exts import db

AuthorToBook = db.Table("AuthorToBook",
                        db.Column("authorID", db.Integer, db.ForeignKey("Author.authorID")),
                        db.Column("isbn", db.Integer, db.ForeignKey("Book.isbn"))
                        )
