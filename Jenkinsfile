pipeline {
    agent any
    triggers {
        pollSCM('* * * * *')
    }
    environment {
        SONAR_URL = 'http://localhost:9000'
        PROJECT_KEY = 'devsecops-project'
        SONAR_TOKEN = credentials('sonar-token')
        SONARQUBE_URL = 'http://localhost:9000'
        DEPENDENCY_TRACK_URL = 'http://localhost:8081'  // Dependency Track Server
        DEPENDENCY_TRACK_API_KEY = credentials('api-key-dependency-track')  // Store API Key in Jenkins Credentials
    }
    stages {
        stage('Clone Repository') {
            steps {
                echo 'Pulling the project from Github...'
                git url: 'https://github.com/the-one-rvs/DevSecOps-Pipeline.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                sh 'npm install'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Running SonarQube Analysis...'
                withSonarQubeEnv('SonarQube') {
                   sh """
                    npx sonarqube-scanner \
                      -Dsonar.projectKey=${PROJECT_KEY} \
                      -Dsonar.sources=. \
                      -Dsonar.exclusions=reports/dependency-check-report.html,trivy-report.json \
                      -Dsonar.host.url=${SONARQUBE_URL} \
                      -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                echo 'Running Dependency Check...'
                dependencyCheck additionalArguments: '--format HTML --out reports/', odcInstallation: 'OWASP Dependency-Check'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker Image...'
                    def buildNumber = env.BUILD_NUMBER
                    sh "docker build -t quasarcelestio/devsecops:build-${buildNumber} ."
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                script {
                    echo 'Running Trivy Scan...'
                    def buildNumber = env.BUILD_NUMBER
                    sh "trivy image --format json --output trivy-report.json quasarcelestio/devsecops:build-${buildNumber}"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def buildNumber = env.BUILD_NUMBER
                    echo 'Pushing Docker Image to DockerHub...'
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
                    def buildNumber = env.BUILD_NUMBER
                    sh "trivy sbom --format cyclonedx --output sbom.json quasarcelestio/devsecops:build-${buildNumber}"
                    archiveArtifacts artifacts: 'sbom.json', fingerprint: true
                }
            }
        }

        stage('Upload SBOM to Dependency Track') {
            steps {
                script {
                    echo 'Uploading SBOM to OWASP Dependency Track...'
                    sh """
                        curl -X POST "$DEPENDENCY_TRACK_URL/api/v1/bom" \
                            -H "X-Api-Key: $DEPENDENCY_TRACK_API_KEY" \
                            -H "Content-Type: application/json" \
                            --data-binary @sbom.json \
                            -d '{"project":"8606a150-e9b5-4e59-9803-2c89c379fa93", "autoCreate": true}'
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Removing Docker Image from local...'
            script {
                def buildNumber = env.BUILD_NUMBER
                sh "docker rmi quasarcelestio/devsecops:build-${buildNumber}" || true
            }
        }
        failure {
            echo 'Build failed, cleaning up Docker Image...'
            script {
                def buildNumber = env.BUILD_NUMBER
                sh "docker rmi quasarcelestio/devsecops:build-${buildNumber}" || true
            }
        }
    }
}
