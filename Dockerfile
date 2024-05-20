FROM openjdk:17
WORKDIR /app
COPY petclinic/target/*.jar appdemo.jar
EXPOSE 8080
CMD ["java", "-jar", "appdemo.jar"]
