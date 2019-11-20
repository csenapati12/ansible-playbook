pipeline {
    agent none   
    stages {
        stage('Ansible Integration') {
           	agent { label 'COE-slave' }
            steps {
               script{              
                sh """
				ansible --version
                """
               }  
            }
        }
      
}
