FROM alpine/openssl:3.5.4

WORKDIR /

COPY ./script.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
