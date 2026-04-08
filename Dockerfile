# Cloud build entrypoint.
# The platform seems to look for `Dockerfile` in repository root.

FROM maven:3.9.9-eclipse-temurin-8 AS builder
WORKDIR /app

COPY backend/pom.xml .
COPY backend/src ./src

RUN mvn -q -DskipTests package

FROM eclipse-temurin:8-jre
WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080
ENV TZ=Asia/Shanghai
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

