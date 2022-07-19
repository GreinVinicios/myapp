def gv

pipeline {
  agent {label 'jenkinsci-jenkins-agent'}
  parameters {
    choice(name: 'VERSION', choices: ['1.1.0', '1.2.0', '1.3.0'], description: '')
    booleanParam(name: 'executeTests', defaultValue: true, description: '')
  }
  environment {
    DOCKER_CERT_PATH = credentials('dockerhub')
    registry = "greinvinicios/myapp"
    registryCredential = 'dockerhub'
    dockerImage = ''
  }
  stages {
    stage("init") {
      steps {
        script {
          gv = load "script.groovy" 
        }
      }
    }
    stage("build") {
      steps {
        script {
          gv.buildApp()
        }
      }
    }
    stage("test") {
      when {
        expression {
          params.executeTests
        }
      }
      steps {
        script {
          gv.testApp()
        }
      }
    }
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build registry + ":$BUILD_NUMBER"
        }
      }
    }
    stage('Deploy Image') {
      steps{
        script {
          docker.withRegistry( '', registryCredential ) {
            dockerImage.push()
          }
        }
      }
    }
    stage('Remove Unused docker image') {
      steps{
        sh "docker rmi $registry:$BUILD_NUMBER"
      }
    }
    stage('Git cloning') {
      steps {
        git branch: 'main', url: 'https://github.com/GreinVinicios/devops.git'
      }
    }
    stage("Image changing") {
      steps {
        sh('echo "myapp: \n image: greinvinicios/myapp:\$BUILD_NUMBER" > chart/imgValues.yaml')
      }
    }
    stage("Image commit") {
      steps {
        sh('''
          git config user.name 'Vinicios Grein'
          git config user.email 'vinicios.grein@gmail.com'
          git add . && git commit -am "[Jenkins CI] Change image number"
        ''')
      }
    }
    stage("Commit push") {
      environment {
        GIT_AUTH = credentials('github')
      }
      steps {
        sh('''
          git config --local credential.helper "!f() { echo username=\\$GIT_AUTH_USR; echo password=\\$GIT_AUTH_PSW; }; f"
          git push --set-upstream origin main
        ''')
      }
    }
    stage("deploy") {
      steps {
        script {
          gv.deployApp()
        }
      }
    }
  }   
}
