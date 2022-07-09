FROM kinshy-docker.pkg.coding.net/south/cross/maven:3.6-jdk-8-alpine AS builder
WORKDIR /app
RUN mkdir jar
COPY ./code ./code
RUN  cd code && mvn clean && mvn -e -B package
COPY copy.sh .
RUN chmod +x copy.sh && ./copy.sh

FROM openjdk:8-jre-alpine
ENV JAVA_OPTS="-Xms128m -Xmx256m"
ENV ACTIVE="dev"
ENV JARNAME="ruoyi-gateway.jar"
COPY ./code/third/skywalking-agent  /app/
ENV SW_AGENT="-javaagent:/app/skywalking-agent/skywalking-agent.jar \
              -Dskywalking.agent.service_name=ruoyi-gateway \
              -Dskywalking.collector.backend_service=sk-skywalking-oap.os:11800"

ENV ELASTIC_APM="-javaagent:/app/elastic-apm-agent-1.28.4.jar \
                -Delastic.apm.service_name={JOB_NAME} \
                -Delastic.apm.server_urls=http://apm-apm-http.os.svc:8200 \
                -Delastic.apm.secret_token=sy7p3mC4h8RNi500o4t0Ff8w \
                -Delastic.apm.environment={ENV} \
                -Delastic.apm.application_packages=org.kili \
                -Dfile.encoding=UTF-8"

WORKDIR /app
# copy jar
COPY --from=builder /app/jar/*.jar /app/
#使用 shell 处理
ENTRYPOINT ["sh", "-c", "java $SW_AGENT $JAVA_OPTS -jar -Duser.timezone=GMT+8 /app/$JARNAME --spring.profiles.active=$ACTIVE "]
