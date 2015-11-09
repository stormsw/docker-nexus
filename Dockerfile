# it's better to switch into Oracle JRE based image
FROM stormsw/ubuntu-java
#stormsw/nexus
# Run with dockerized data container:
# docker run -d --name nexus-data stormsw/nexus echo "data-only container for Nexus"
# docker run -d -p 8081:8081 --name nexus --volumes-from nexus-data stormsw/nexus
#
# Volume data:
# mkdir /some/dir/nexus-data
# docker run -d -p 8081:8081 --name nexus -v /some/dir/nexus-data:/sonatype-work stormsw/nexus
#
MAINTAINER Alexander Varchenko <alexander.varchenko@gmail.com>
# default
EXPOSE 8081
# switch to nexus
#ENV DEBIAN_FRONTEND noninteractive
ENV SONATYPE_WORK /sonatype-work
ENV NEXUS_VERSION 3.0.0-m5 
VOLUME ${SONATYPE_WORK}
WORKDIR /opt/sonatype/nexus
RUN curl --fail --silent --location --retry 3 \
    https://download.sonatype.com/nexus/oss/nexus-${NEXUS_VERSION}-bundle.tar.gz \
  | tar xvz --strip-components=1
#  && mv nexus-${NEXUS_VERSION}*/ /opt/sonatype/nexus/ 
#  && rm -rf nexus-${NEXUS_VERSION}
#1000 is a first user on Debian/Ubunto, so it should work
RUN useradd -r -u 1000 -m -c "Nexus service" -d ${SONATYPE_WORK} -s /bin/false nexus
#WORKDIR /opt/sonatype/nexus
RUN chown -R nexus:nexus /opt/sonatype $SONATYPE_WORK
USER nexus
ENV CONTEXT_PATH /
ENV MAX_HEAP 768m
ENV MIN_HEAP 256m
ENV JAVA_OPTS -server -XX:MaxPermSize=192m -Djava.net.preferIPv4Stack=true
ENV LAUNCHER_CONF ./conf/jetty.xml ./conf/jetty-requestlog.xml
# can be used for datacontainer mode
VOLUME ${SONATYPE_WORK}
CMD java \
    -Dnexus-work=${SONATYPE_WORK} -Dnexus-webapp-context-path=${CONTEXT_PATH} \
    -Xms${MIN_HEAP} -Xmx${MAX_HEAP} \
    -cp 'conf/:lib/*' \
    ${JAVA_OPTS} \
    org.sonatype.nexus.bootstrap.Launcher ${LAUNCHER_CONF}
