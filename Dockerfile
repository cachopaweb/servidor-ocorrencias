FROM jacobalberty/firebird

ENV DB_HOST=portalsoft.sytes.net:/home/Portal/Dados/PORTAL.FDB
ENV DB_HOST_LICENCAS=firebird.db5.net2.com.br:/firebird/portalsoft2.gdb
ENV DB_USER=PORTALSOFT2
ENV DB_PASS=portal3694

COPY ./ServidorOS ./app/ServidorOS

RUN chmod 777 ./app/ServidorOS

EXPOSE 9000

ENTRYPOINT ./app/ServidorOS