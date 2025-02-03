# Gunakan image Python yang ringan
FROM python:3.8-slim

# Menetapkan direktori kerja di dalam container
WORKDIR /app

# Menyalin file requirements ke dalam container
COPY requirements.txt /app/

# Menginstall dependencies di dalam container
RUN pip install --no-cache-dir -r requirements.txt

# Menyalin semua file proyek ke container
COPY . /app

# Menentukan perintah untuk dijalankan dalam container
CMD ["python", "app.py"]
