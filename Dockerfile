FROM ibmjava:8-jre
#FROM maven:3.6.0-ibmjava-8

COPY ./target/liberty/.  /

RUN cd /

RUN ls -la

CMD ["/wlp/bin/server", "run", "BoostServer"]