pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="367022636628"
        AWS_DEFAULT_REGION="ap-south-1" 
        IMAGE_REPO_NAME="jenkins-docker-pipeline"
        IMAGE_TAG="IMAGE_TAG"
        REPOSITORY_URI = "${367022636628}.dkr.ecr.${ap-south-1}.amazonaws.com/${public.ecr.aws/m9i9n7s1/jenkins-docker-pipeline}"
    }
   
    stages {
        
         stage('Logging into AWS ECR') {
            steps {
                script {
                sh "aws ecr get-login-password --region ${ap-south-1} | docker login --username AWS --password-stdin ${367022636628}.dkr.ecr.${ap-south-1}.amazonaws.com"
                }
                 
            }
        }
        
        stage('Cloning Git') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '', url: 'https://github.com/ajaydspl/jenkins-docker-pipeline.git']]])    
            }
        }
  
    // Building Docker images
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build "${jenkins-docker-pipeline}:${IMAGE_TAG}"
        }
      }
    }
   
    // Uploading Docker images into AWS ECR
    stage('Pushing to ECR') {
     steps{  
         script {
                sh "docker tag ${jenkins-docker-pipeline}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"
                sh "docker push ${367022636628}.dkr.ecr.${ap-south-1}.amazonaws.com/${jenkins-docker-pipeline}:${IMAGE_TAG}"
         }
        }
      }
    }
}