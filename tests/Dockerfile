FROM python:3.11-alpine

COPY test.py requirements.txt ./

RUN apk add --no-cache curl
RUN pip install --no-cache-dir -r requirements.txt

CMD ["pytest", "test.py", "-v"]



