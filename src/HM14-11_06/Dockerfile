# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set environment variables to prevent Python from writing pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory in the container
WORKDIR /app

# Copy requirements.txt to the working directory
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY app.py .
COPY students.csv .

# Expose port 8000 for the Gunicorn server
EXPOSE 8000

# Command to run the Flask application using Gunicorn on port 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
