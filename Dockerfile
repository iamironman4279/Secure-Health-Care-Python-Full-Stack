# Assuming you're using python base image
FROM python:3.10

WORKDIR /app

COPY . .

# Install system dependencies for mysqlclient
RUN apt-get update && apt-get install -y \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --upgrade pip && pip install -r requirements.txt
EXPOSE 5000

# Command to run the Flask app
CMD ["python", "app.py"]