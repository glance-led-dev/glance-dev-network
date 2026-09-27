FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && useradd --uid 10001 --create-home companion && mkdir /data && chown companion /data
COPY server.py xbox.py ./
USER companion
EXPOSE 8080
CMD ["python", "server.py"]
