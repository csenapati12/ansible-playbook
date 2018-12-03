node(){
    
    stage('cloning the code'){
        checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], gitTool: 'Default', submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/csenapati12/ansible-playbook.git']]])
    }
     
    stage('Building the code'){
        echo 'Building the code'
    }
    
     
    stage('Sonarqube analysis'){
        echo 'Sonar analayis'
    }
}
