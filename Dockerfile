FROM ibmjava:8-jre
#FROM maven:3.6.0-ibmjava-8

RUN apt-get update
RUN apt-get -y install vim
RUN apt-get -y install curl
RUN apt-get -y install zip

COPY ./target/liberty/.  /
COPY ./target/microprofile-health-1.0-SNAPSHOT.war /wlp/usr/servers/BoostServer/apps/
RUN rm -rf /wlp/usr/servers/BoostServer/apps/*.xml

EXPOSE 9080

# Set Path Shortcuts
ENV PATH=/wlp/bin:/opt/ol/docker/:$PATH \
    LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/wlp/output \
    WLP_SKIP_MAXPERMSIZE=true

#RUN mkdir /logs \
#    && mkdir -p $WLP_OUTPUT_DIR/BoostServer \
#    && ln -s $WLP_OUTPUT_DIR/BoostServer /output \
#    && ln -s /wlp/usr/servers/BoostServer /config \
#    && ln -s /logs $WLP_OUTPUT_DIR/BoostServer/logs \
#    && ln -s /liberty /wlp

CMD ["/wlp/bin/server", "run", "BoostServer"]