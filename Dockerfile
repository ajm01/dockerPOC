FROM maven:3.6.0-ibmjava-8 AS MAVEN_TOOL_CHAIN

RUN apt-get update
RUN apt-get -y install git --fix-missing

#build boost
RUN mkdir /tmp/boostrepo
WORKDIR /tmp/boostrepo
RUN git clone https://github.com/OpenLiberty/boost.git
WORKDIR /tmp/boostrepo/boost

RUN ./boost-maven.sh

#boost package the app
COPY pom.xml /tmp/
COPY src /tmp/src/
WORKDIR /tmp/ 
RUN mvn package

#config the env to run app
FROM ibmjava:8-jre
COPY --from=MAVEN_TOOL_CHAIN /tmp/target/liberty/.  /
COPY --from=MAVEN_TOOL_CHAIN /tmp/target/microprofile-health-1.0-SNAPSHOT.war /wlp/usr/servers/BoostServer/apps/

RUN rm -rf /wlp/usr/servers/BoostServer/apps/*.xml

RUN apt-get update
RUN apt-get -y install vim
RUN apt-get -y install curl
RUN apt-get -y install zip
RUN apt-get -y install maven

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