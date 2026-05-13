# 1단계: Maven으로 build
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline

COPY . .
RUN mvn clean package -DskipTests


# 2단계: Tomcat 실행 (war 배포)
FROM tomcat:10.1-jdk17

# 기존 ROOT 제거
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# build 결과 war 복사
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]