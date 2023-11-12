FROM python:3.11-slim-bookworm

ENV PYTHONUNBUFFERED 1

# set container username
ARG USERNAME=django-user

# set this to 1 to build container with dev packages
ARG DEVELOPMENT=0

# set work directory for container
WORKDIR /app

# change default shell to bash
SHELL ["/bin/bash", "-c"]

# install OS dependencies
RUN apt-get update \
    && apt-get --no-install-recommends install -y curl libmagic1 \
    && apt-get clean

# install poetry
RUN curl -sSL \
    https://install.python-poetry.org \
    | python - --version 1.7.0
ENV PATH="${PATH}:/root/.local/bin"
RUN poetry config virtualenvs.create false

# install packages
COPY poetry.lock pyproject.toml ./
RUN if [ "${DEVELOPMENT}" = "1" ]; \
    then \
        poetry install; \
    else \
        poetry install --no-dev; \
    fi

# copy code files to container
COPY ./app /app

# add non-root user
RUN useradd -u 1000 -m ${USERNAME} -l -r
USER ${USERNAME}

# open require ports
EXPOSE 8000

# run app server
# CMD []