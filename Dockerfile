FROM ubuntu:16.04 as codigo

CMD [ "sudo mkdir /home/Portal/Dados/" ]

WORKDIR /home/Portal/Dados/

COPY PORTAL.FDB /home/Portal/Dados

CMD [ "sudo chmod 777 /home/Portal/Dados/PORTAL.FDB" ]

CMD [ "sudo apt-get install libfbclient2"]

CMD ["sudo ln -s /usr/lib/x86_64-linux-gnu/libfbclient.so.2 /usr/lib/x86_64-linux-gnu/libfbclient.so"]

WORKDIR /bin

CMD [ "chmod 777 /bin" ]

COPY LinuxPAServer19.0.tar.gz /bin

RUN tar -xvf LinuxPAServer19.0.tar.gz

WORKDIR /bin/PAServer-19.0

CMD ["/bin/PAServer-19.0/paserver", "-password="]

EXPOSE 64211