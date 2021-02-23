FROM python:alpine3.8

ENV FLASK_APP=bookmarkt.py

copy . /app

workdir /app

run pip install -r requirements.txt

EXPOSE 5000

CMD [ "flask", "run", "--host", "0.0.0.0" ]
