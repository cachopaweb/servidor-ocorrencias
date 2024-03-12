FROM jacobalberty/firebird

ENV DB_HOST=
ENV DB_USER=
ENV DB_PASS=

RUN apt-get update -y && apt upgrade -y && apt-get dist-upgrade -y
# RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libcurl4-gnutls-dev

COPY ./ServidorOS ./app/ServidorOS

EXPOSE 8080

ENTRYPOINT ./app/ServidorOS
