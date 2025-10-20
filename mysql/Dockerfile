#
# Build Stage
#
FROM maven:3.8.6-openjdk-8 AS build

WORKDIR /opt/shipping

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

#
# Runtime Stage
#
FROM openjdk:8-jre-slim

WORKDIR /opt/shipping

ENV CART_ENDPOINT=cart:8080
ENV DB_HOST=mysql

COPY --from=build /opt/shipping/target/shipping-1.0.jar shipping.jar

EXPOSE 8080

CMD ["java", "-Xmn256m", "-Xmx768m", "-jar", "shipping.jar"]
