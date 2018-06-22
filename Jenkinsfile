node {
    def app
    
    stage('Clone repository') {
        checkout scm
    }
    
    stage('Build image') {
        app = docker.build("banderson/drupal")
    }
    
    stage('Test image') {
        app.inside {
            sh 'curl http://localhost:80 || exit 1'
        }
}
    
    stage('Push image') {
        docker.withRegistry('https://hub.docker.com', 'docker-hub-credentials') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }
}
