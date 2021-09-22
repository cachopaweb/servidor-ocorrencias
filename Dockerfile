FROM jacobalberty/firebird

ENV DB_HOST=
ENV DB_HOST_LICENCAS=
ENV DB_USER=
ENV DB_PASS=

COPY ./ServidorOS ./app/ServidorOS

RUN chmod 777 ./app/ServidorOS

EXPOSE 9000

ENTRYPOINT ./app/ServidorOS
