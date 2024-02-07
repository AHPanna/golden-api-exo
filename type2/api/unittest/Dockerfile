# Utiliser l'image officielle de PySpark
FROM bitnami/spark:latest

# Copier le code source dans l'image
COPY . /app

# Définir le répertoire de travail
WORKDIR /app

# Installer les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Exécuter les tests unitaires
CMD ["python", "-m", "unittest", "test_file.py"]
