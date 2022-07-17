FROM python:3.8-slim-buster
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
EXPOSE 8000
COPY . .
CMD [ "gunicorn", "-b", "0.0.0.0:8000", "--log-level" , "debug", "api:app"]
