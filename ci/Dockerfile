FROM ruoyi-init AS builder

FROM  openjdk:8-jre-alpine

ARG buildname=ruoyi-gateway

ENV JARNAME="ruoyi-gateway.jar"
ENV JAVA_OPTS="-Xms128m -Xmx256m"
ENV ACTIVE="dev"

WORKDIR /app

COPY --from=builder /app/${buildname}.jar /app/${buildname}.jar

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar -Duser.timezone=GMT+8 /app/$JARNAME --spring.profiles.active=$ACTIVE "]