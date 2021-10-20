FROM postgres

RUN apt-get update && apt-get install postgresql-13-wal2json
ENV POSTGRES_PASSWORD=mysecretpassword
ENV POSTGRES_DB=player

COPY dbscrip/ /docker-entrypoint-initdb.d/
