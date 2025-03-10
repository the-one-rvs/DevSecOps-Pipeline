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
        DEPENDENCY_TRACK_URL = 'http://localhost:8080'  // Dependency Track Server
        DEPENDENCY_TRACK_API_KEY = credentials('api-key-dependency-track')  // Store API Key in Jenkins Credentials

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
        }

        stage('Generate SBOM') {
            steps {
                script {
                    echo 'Generating SBOM using Trivy...'
                    sh 'trivy sbom --format cyclonedx --output sbom.json .'
                    archiveArtifacts artifacts: 'sbom.json', fingerprint: true
                }
            }
        }

        stage('Upload SBOM to Dependency Track') {
            steps {
                script {
                    echo 'Uploading SBOM to OWASP Dependency Track...'
                    sh """
                        curl -X PUT "$DEPENDENCY_TRACK_URL/api/v1/bom" \
                            -H "X-Api-Key: $DEPENDENCY_TRACK_API_KEY" \
                            -H "Content-Type: application/json" \
                            --data-binary @sbom.json
                    """
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