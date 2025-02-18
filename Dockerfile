FROM python:3.12.7-slim-bullseye

WORKDIR /usr/src/app

COPY requirements.txt main.py ./

RUN pip install --no-cache-dir -r requirements.txt

CMD [ "python", "./main.py" ]