FROM python:slim
LABEL maintainer="rabdill@umn.edu"

ADD . /app
WORKDIR /app
RUN pip install -r requirements.txt

CMD ["python", "main.py"]
