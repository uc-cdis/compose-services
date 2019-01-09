#!groovy

pipeline {
  agent any

  environment {
    KLOCK_USER = "jenkins" + new Random().nextInt()
  }

  stages {
    stage('FetchCode') {
      steps {
        checkout scm  
        dir('cloud-automation') {
          git(
            url: 'https://github.com/uc-cdis/cloud-automation.git',
            branch: 'master'
          )
        }
        script {
          env.GEN3_HOME=env.WORKSPACE+'/cloud-automation'
          env.GEN3_NOPROXY='true'
        }
      }
    }
    stage('docker pull') {
      steps {
        sh('docker-compose pull')
      }
    }
    stage('AcquireLock') {
      steps {
        script {
          // acquire global lock to launch docker services on Jenkins host node
          def lockStatus = sh( script: "bash cloud-automation/gen3/bin/klock.sh lock dockerTest ${env.KLOCK_USER} 3600 -w 600", returnStatus: true)
          if (lockStatus != 0) {
            error("unable to acquire dockerTest lock")
          }
        }
      }
    }
    stage('docker up') {
      steps {
        sh 'sudo docker-compose down || true'
        sh 'sudo docker-compose up -d'
      }
    }
    stage('smoke test') {
      steps {
        dir('testResults') {
          script {
            // get the IP address of the node Jenkins is running on
            def ipAddress = sh(script: "kubectl describe pod -l app=jenkins | grep Node: | sed 's@^.*/@@'", returnStdout: true)
            retry(10) { // retry smoke_test up to 10 times
              sleep(60) // give the services some time to start up
              sh(script: "bash ./smoke_test.sh")
            }
          }
        }
      }
    }
  }
  post {
    success {
      echo "https://jenkins.planx-pla.net/ $env.JOB_NAME pipeline succeeded"
    }
    failure {
      echo "Failure!"
      //archiveArtifacts artifacts: '**/output/*.png', fingerprint: true
      //slackSend color: 'bad', message: "https://jenkins.planx-pla.net $env.JOB_NAME pipeline failed"
    }
    unstable {
      echo "Unstable!"
      //slackSend color: 'bad', message: "https://jenkins.planx-pla.net $env.JOB_NAME pipeline unstable"
    }
    always {
      script {
        uid = env.service+"-"+env.quaySuffix+"-"+env.BUILD_NUMBER
        withEnv(['GEN3_NOPROXY=true', "GEN3_HOME=$env.WORKSPACE/cloud-automation"]) {         
          sh("bash cloud-automation/gen3/bin/klock.sh unlock dockerTest ${env.KLOCK_USER} || true")
        }
      }
      echo "done"
    }
  }
}
