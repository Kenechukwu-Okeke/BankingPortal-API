# FROM openjdk:11-jdk-slim
# ARG JAR_FILE=target/*.jar
# COPY ${JAR_FILE} app.jar
# EXPOSE 8080
# ENTRYPOINT ["java", "-jar", "/app.jar"]





# ---------- Build stage ----------
FROM eclipse-temurin:21-jdk AS build
 
WORKDIR /app
 
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .
RUN chmod +x mvnw
COPY src ./src


RUN ./mvnw clean package -Dmaven.test.skip=true
 


# ---------- Runtime stage ----------
FROM eclipse-temurin:21-jre AS runtime
 
WORKDIR /app
 
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
 
COPY --from=build /app/target/*.jar app.jar
 
RUN chown -R appuser:appgroup /app
 
USER appuser
 
EXPOSE 8180
 
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8180/actuator/health || exit 1
 
ENTRYPOINT ["java", "-jar", "app.jar"]
 