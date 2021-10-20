FROM atmoz/sftp
USER root:root

RUN mkdir -p /home/foo/upload/csv/source
RUN mkdir -p /home/foo/upload/csv/error
RUN mkdir -p /home/foo/upload/csv/output
COPY ./csv-sftp-source.csv /home/foo/upload/csv/source

RUN mkdir -p  /home/foo/upload/file/data
RUN mkdir -p  /home/foo/upload/file/error
RUN mkdir -p  /home/foo/upload/file/finished
COPY ./hello_world.html /home/foo/upload/file/data

RUN chmod -R 777 /home/foo/upload
