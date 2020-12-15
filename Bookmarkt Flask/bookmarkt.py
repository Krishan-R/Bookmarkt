import flask

app = flask.Flask(__name__)
app.config["DEBUG"] = True


@app.route('/', methods=['GET'])
def home():
    return "<h1>Home</h1>"

@app.route("/api/v1/resources/books/all", methods=["GET"])
def api_all():
    return "abc"