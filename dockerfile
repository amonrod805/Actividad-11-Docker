# ===================================================================
# Dockerfile seguro - Python (Flask)
# ===================================================================

# ---------- Etapa 1: instalación de dependencias (builder) ----------

# 1. Imagen base: versión específica y ligera (nunca :latest)
FROM python:3.12.7-slim-bookworm AS builder

# 2. Entorno y directorio de trabajo
ENV PYTHONDONTWRITEBYTECODE=1
WORKDIR /app

# Entorno virtual para copiar solo las dependencias a la imagen final
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 3. Copiar los manifiestos de dependencias (antes del código, para la caché de capas)
COPY requirements.txt .

# 4. Instalación limpia de dependencias de producción sin dejar caché
RUN pip install --no-cache-dir -r requirements.txt


# ---------- Etapa 2: imagen final de ejecución ----------

# 1. Imagen base de ejecución (misma versión fija)
FROM python:3.12.7-slim-bookworm

# 2. Entorno y directorio de trabajo
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"
WORKDIR /app

# Crear usuario y grupo sin privilegios (la imagen de Python no trae uno)
RUN groupadd --system appgroup \
    && useradd --system --gid appgroup --no-create-home appuser

# Copiar solo las dependencias ya instaladas desde la etapa anterior
COPY --from=builder /opt/venv /opt/venv

# 5. Copiar el código fuente cambiando la propiedad al usuario sin privilegios...
COPY --chown=appuser:appgroup app.py .
# ...y cambiar a ese usuario
USER appuser

# 6. Puerto de escucha
EXPOSE 8080

# 7. Comando de arranque (exec form)
CMD ["python", "app.py"]
