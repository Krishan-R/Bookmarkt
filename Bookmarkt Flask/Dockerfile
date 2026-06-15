FROM python:3.11-alpine

ENV FLASK_APP=bookmarkt.py
ENV PYTHONUNBUFFERED=1

COPY . /bookmarkt

WORKDIR /bookmarkt

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD [ "python", "-m", "flask", "run", "--host", "0.0.0.0" ]
