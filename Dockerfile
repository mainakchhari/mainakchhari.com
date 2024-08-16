# syntax=docker/dockerfile:1
FROM python:3.12-slim as builder
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
RUN pip install poetry==1.8.3
ENV POETRY_NO_INTERACTION=1 \
  POETRY_VIRTUALENVS_IN_PROJECT=1 \
  POETRY_VIRTUALENVS_CREATE=1 \
  POETRY_CACHE_DIR=/tmp/poetry_cache
WORKDIR /app
COPY poetry.lock pyproject.toml ./
RUN poetry install --no-root --only=main
COPY . ./
RUN poetry run python manage.py collectstatic --no-input

FROM python:3.12-slim as production
ENV VIRTUAL_ENV=/app/.venv \
  PATH="/app/.venv/bin:$PATH" \
  PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1 \
  STATIC_ROOT=/app/staticfiles
WORKDIR /app
COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}
COPY --from=builder ${STATIC_ROOT} ${STATIC_ROOT}
COPY . ./
