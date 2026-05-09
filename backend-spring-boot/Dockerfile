# Build stage
FROM eclipse-temurin:21-jdk-jammy AS builder
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*
WORKDIR /build
COPY pom.xml .
COPY src ./src
RUN mvn -B clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# Create non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Copy jar from builder
COPY --from=builder /build/target/*.jar app.jar

# Create log directory and set permissions
RUN mkdir -p /app/logs && chown -R appuser:appgroup /app/logs

# Expose correct port
EXPOSE 8081

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8081/actuator/health/readiness || exit 1

# Switch to non-root user
USER appuser

# Set JVM memory flags and run jar
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
