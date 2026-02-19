# Use Java 17 runtime image
FROM eclipse-temurin:17-jdk-alpine

# Set working directory inside container
WORKDIR /app

# Copy built JAR file from target folder
COPY target/springboot-demo-0.0.1-SNAPSHOT.jar app.jar

# Expose application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java","-jar","app.jar"]
