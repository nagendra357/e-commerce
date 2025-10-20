#
# Build Stage
#

FROM maven:3.8.6-openjdk-8 AS build

WORKDIR /opt/shipping

# Copy pom.xml and download dependencies (use cache if unchanged)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the rest of the source code
COPY src ./src

# Build the JAR file
RUN mvn clean package -DskipTests

#
# Runtime Stage
#
FROM openjdk:8-jre-slim

WORKDIR /opt/shipping

# Set environment variables
ENV CART_ENDPOINT=cart:8080
ENV DB_HOST=mysql

# Copy the built jar from build stage
COPY --from=build /opt/shipping/target/shipping-1.0.jar shipping.jar

# Expose the application port
EXPOSE 8080

# Run the application
CMD ["java", "-Xmn256m", "-Xmx768m", "-jar", "shipping.jar"]
