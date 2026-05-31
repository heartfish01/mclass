# jdk 17 도커 이미지를 다운로드
FROM eclipse-temurin:17-jdk

# JAR 파일이 저장될 작업 디렉토리 설정
WORKDIR /app

# Maven 또는 Gradle 빌드 후 생성된 JAR 파일을 컨테이너 내부 /app 디렉토리에 app.jar 이름으로 복사
COPY app.jar app.jar
# 앞에께 호스트경로, 뒤에가 도커이미지 내 복사될 경로. -  [앞에: 내 로컬/호스트의 파일] [뒤에: 도커 이미지 안에 복사될 위치]
# 참고로 demo.snaptshort.jar 를 app.jar로 이름변경해서사용할거다.

# 실행 포트 지정
# 이미 8081로 설정해두긴했으나, 보는사람도 8081알수있게 또해둔거다.
EXPOSE 8081

# 컨테이너 실행 시 JAR 실행
# 빌드된 jar 파일을 실행하는 것으로 컨테이너내에서실행되는거다.
ENTRYPOINT ["java", "-jar", "app.jar"]

