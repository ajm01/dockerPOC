FROM maven:3.6.0-ibmjava-8 AS MAVEN_TOOL_CHAIN

RUN apt-get update && apt-get -y install git --fix-missing

#build boost
RUN mkdir -p /tmp/boostrepo
WORKDIR /tmp/boostrepo

# only clone boost if there is something new in boost repo
ARG SHA=LATEST
RUN SHA=${SHA} \
    git clone https://github.com/OpenLiberty/boost.git &&\
	cd boost &&\
	./boost-maven.sh
	

RUN apt-get update
RUN apt-get -y install apt-utils
RUN apt-get -y install vim
RUN apt-get -y install curl
RUN apt-get -y install zip

#boost package the app
WORKDIR /tmp/
COPY pom.xml /tmp/
RUN mvn dependency:resolve
COPY src /tmp/src/
RUN mvn package

#config the env to run app
FROM ibmjava:8-jre
RUN mkdir wlp
COPY --from=MAVEN_TOOL_CHAIN /tmp/target/liberty/wlp/bin/.  /wlp
COPY --from=MAVEN_TOOL_CHAIN /tmp/target/liberty/wlp/clients/.  /wlp
COPY --from=MAVEN_TOOL_CHAIN /tmp/target/liberty/wlp/dev/.  /wlp
COPY --from=MAVEN_TOOL_CHAIN /tmp/target/liberty/wlp/lib/.  /wlp
COPY --from=MAVEN_TOOL_CHAIN /tmp/target/liberty/wlp/templates/.  /wlp
COPY --from=MAVEN_TOOL_CHAIN /tmp/target/liberty/wlp/.installed  /wlp
COPY --from=MAVEN_TOOL_CHAIN /tmp/target/liberty/wlp/LICENSE  /wlp
COPY --from=MAVEN_TOOL_CHAIN /tmp/target/liberty/wlp/NOTICES  /wlp
COPY --from=MAVEN_TOOL_CHAIN /tmp/target/liberty/wlp/README.TXT  /wlp

COPY --from=MAVEN_TOOL_CHAIN /tmp/target/liberty/wlp/usr/.  /wlp
COPY --from=MAVEN_TOOL_CHAIN /tmp/target/microprofile-health-1.0-SNAPSHOT.war /wlp/usr/servers/BoostServer/apps/

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