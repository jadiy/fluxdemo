FROM ruoyi-init AS builder

FROM  openjdk:8-jre-alpine

ARG buildname=ruoyi-gateway

ENV JARNAME="ruoyi-gateway.jar"
ENV JAVA_OPTS="-Xms128m -Xmx256m"
ENV ACTIVE="dev"
ENV SW_AGENT="-javaagent:/app/skywalking-agent.jar \
              -Dskywalking.agent.service_name=${buildname} \
              -Dskywalking.collector.backend_service=sk-skywalking-oap.os:11800"
COPY --from=builder /app/skywalking-agent.jar /app/skywalking-agent.jar
WORKDIR /app

COPY --from=builder /app/${buildname}.jar /app/${buildname}.jar

ENTRYPOINT ["sh", "-c", "java $SW_AGENT $JAVA_OPTS -jar -Duser.timezone=GMT+8 /app/$JARNAME --spring.profiles.active=$ACTIVE "]