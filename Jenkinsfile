pipeline {
    agent any   
    stages {
        stage('Ansible Integration') {
           	
            steps {
               script{              
                sh """
				ansible --version
				ansible-playbook deployfile.yml
                """
	       }
            }
        }
    }  
}
