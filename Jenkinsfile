pipeline {
    agent any

    environment {
        PATH = "/opt/homebrew/bin:/Users/midhtech_01/.docker/bin:${env.PATH}"
    }

    stages {

        stage('Unit Test') {
            steps {
                dir('frontend') {
                    sh 'npm test'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'

                    withSonarQubeEnv('SonarQube') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    env.IMAGE_TAG = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()

                    sh "docker build -t 3-tier-app:${env.IMAGE_TAG} backend"
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                    trivy image --exit-code 1 \
                    --severity CRITICAL \
                    3-tier-app:${IMAGE_TAG}
                '''
            }
        }

        stage('Harbor Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'harbour',
                        usernameVariable: 'HARBOR_USER',
                        passwordVariable: 'HARBOR_PASS'
                    )
                ]) {
                    sh '''
                        echo "$HARBOR_PASS" | docker login 192.168.1.121:80 \
                          -u "$HARBOR_USER" --password-stdin

                        docker tag 3-tier-app:${IMAGE_TAG} \
                          192.168.1.121:80/3-tier/3-tier-app:${IMAGE_TAG}

                        docker push \
                          192.168.1.121:80/3-tier/3-tier-app:${IMAGE_TAG}
                    '''
                }
            }
        }
    }
}