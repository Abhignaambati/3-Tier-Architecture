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