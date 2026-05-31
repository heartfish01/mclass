pipeline{
    agent any // 어떤 에이전트(실행 서버)에서든 실행 가능
    
    tools {
        maven 'maven 3.9.12' // Jenkins에 등록된 Maven 3.9.12 를 사용 // 요 maven 3.9.12 이름도 앞서 한거랑 공백하나다르면 연결실패한다.
    }
        
    environment {
                 // 환경도 미리 다 설정하고가자 spring 관련해서 작성하자
        DOCKER_IMAGE = "demo-app" // 도커 이미지 이름
        CONTAINER_NAME = "springboot-container" // 도커 컨테이너 이름
        JAR_FILE_NAME = "app.jar" // 복사할 JAR 파일 이름
        PORT = "8081" // 컨테이너에 연결한 포트 SPRING에서 쓸거. 보통 SPRING 서버랑 JENKINS서버랑 다르게쓰기도하는데 우리는 같은거그냥쓸거다
        
        REMOTE_USER = "ec2-user" // 원격(spring) 서버 사용자
        REMOTE_HOST = "54.116.69.27" // 원격(spring) 서버 IP(Public IP) - SPRING서버 IP

        REMOTE_DIR = "/home/ec2-user/deploy" // 원격 서버에 파일 복사할 경로
        SSH_CREDENTIALS_ID = "9a45ef2f-30d3-4d07-a666-7687fe6bd2b5" // Jenkins SSH 자격 증명 ID : JENKINS UI -> 설정 -> CREDENTIALS -> ID 복사해서넣어주면된다.
    }

    stages {
        stage('Git Checkout') {
            steps { // steps : stage 안에서 실행할 실제 명령어
                // Jenkins에 연결된 Git 저장소에서 최신 코드 체크 아웃
                checkout scm
            }
        }

        stage('Maven Build') {
            steps {
                // 테스트는 건너뛰고 Maven 빌드 수행
                sh 'mvn clean package -DskipTests'
                // sh '' : 리눅스 명령어 실행
            }
        }

        stage('Prepare Jar') {
            steps {
                // 빌드 결과물인 JAR 파일을 지정한 이름(app.jar)으로 복사
                sh 'cp target/demo-0.0.1-SNAPSHOT.jar ${JAR_FILE_NAME}'
            }
        }

        stage('Copy to Remote Server') {
            steps {
                // Jenkins 가 원격 서버에 SSH 접속할 수 있도록 sshagent 사용
                sshagent (credentials: [env.SSH_CREDENTIALS_ID]){ //ssh 플러그인 jenkins webui 에서 설치한거말하는거다 ssh agent가 
                    // 원격 서버에 배포 디렉토리 생성 (없으면 새로 만듦)
                    sh "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${REMOTE_HOST} \"mkdir -p ${REMOTE_DIR}\""
                    // JAR 파일과 Dockerfile을 원격 서버에 복사
                    sh "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${JAR_FILE_NAME} Dockerfile ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"
                }
            }
        }

        stage('Remote Docker Build & Deploy') {
            steps {
                sshagent (credentials : [env.SSH_CREDENTIALS_ID]) { // 아래코드는 indent가 가장앞으로 저렇게 되어야 에러안나더라. 공백뒤에 있어도 에러날때있었고조심하라
                // dockerfile 에 가보면 app.jar  있기에 이거 도커파일에 넣어서 spring 서버에던진다. 그런데 이런거 파일이름하나하나 틀리면 에러나게되는거다
                // rm -f 있느건 이전 도커이미지 지우고 다시 새로하는거다
                // 포트번호는 이미 위에정해둔 ,그것으로 도커이미지와 명령어 있는거다.
                    sh """
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_USER}@${REMOTE_HOST} << ENDSSH
    cd ${REMOTE_DIR} || exit 1
    docker rm -f ${CONTAINER_NAME} || true
    docker build -t ${DOCKER_IMAGE} .
    docker run -d --name ${CONTAINER_NAME} -p ${PORT}:${PORT} ${DOCKER_IMAGE}
ENDSSH
                    """

                }
            }
        }
    }
}