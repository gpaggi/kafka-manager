FROM openjdk:8-jdk-alpine as build
ARG VERSION=1.3.3.14
RUN apk add --no-cache git wget bash \
    && mkdir -p /tmp \
    && cd /tmp \
    && git clone https://github.com/yahoo/kafka-manager \
    && cd /tmp/kafka-manager \
    && git checkout tags/${VERSION} \
    && echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt \
    && ./sbt clean dist \
    && unzip  -d / ./target/universal/kafka-manager-${VERSION}.zip

FROM openjdk:8-alpine
MAINTAINER gpaggi
RUN adduser -S -h /app -u 1200 km
COPY --from=build /kafka-manager* /app/
ENV PATH=/app:${PATH}
USER km
EXPOSE 9000
ENTRYPOINT ["/app/bin/kafka-manager", "-Dconfig.file=conf/application.conf"]