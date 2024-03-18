FROM python:alpine
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY bookstore-api.py app.py
EXPOSE 80
CMD ["python", "./app.py"]