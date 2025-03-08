pipeline{
    agent any
    triggers {
        githubPush()  
        pollSCM('* * * * *')
    }
    environment{
        SONAR_URL = 'http://localhost:9000'
        PROJECT_KEY = 'devsecops-project'
        SONAR_TOKEN = credentials('sonar-token')
        SONARQUBE_URL = 'http://localhost:9000'
    }
    stages{
        stage('Github Repo'){
            steps{
                echo 'Pulling the project from Github...'
                git changelog: false, poll: false, url: 'https://github.com/the-one-rvs/DevSecOps-Pipeline.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                sh 'npm install'
            }
        }

        stage('SonarQube Analysis'){
            steps{
                echo 'Running SonarQube Analysis...'
                withSonarQubeEnv('SonarQube'){
                   sh '''
                    npx sonarqube-scanner \
                      -Dsonar.projectKey=${PROJECT_KEY} \
                      -Dsonar.sources=. \
                      -Dsonar.exclusions=dependency-check-report.html,trivy-report.json \
                      -Dsonar.host.url=${SONARQUBE_URL} \
                      -Dsonar.login=${SONARQUBE_TOKEN}
                    '''
                }
            }
        }

        stage('DP Check'){
            steps{
                dependencyCheck additionalArguments: '--format HTML', odcInstallation: 'OWASP Dependecy-Check'
            }
        }

        stage('DockerImage Create'){
            steps{
                script{
                    echo 'Building Docker Image...'
                    def buildNumber = env.BUILD_NUMBER
                    sh "docker build -t quasarcelestio/devsecops:build-${buildNumber} ."
                }
            }
        }

        stage ('Trivy Scan'){
            steps{
                script{
                    echo 'Running Trivy Scan...'
                    def buildNumber = env.BUILD_NUMBER
                    sh "trivy image --format json --output trivy-report.json quasarcelestio/devsecops:build-${buildNumber}"
                }
            }
        }

        stage('DockerImage Push'){
            steps{
                echo 'Pushing Docker Image to DockerHub...'
                script{
                    def buildNumber = env.BUILD_NUMBER
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhubcred') {
                        sh "docker push quasarcelestio/devsecops:build-${buildNumber}"
                    }
                }
            }
            post {
                always {
                    echo 'Removing Docker Image from local...'
                    script {
                        def buildNumber = env.BUILD_NUMBER
                        sh "docker rmi quasarcelestio/devsecops:build-${buildNumber}"
                    }
                }
            }
        }
        
    }
}