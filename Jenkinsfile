pipeline{
    agent any
    tools{
        jdk 'myjava'
        maven 'mymaven'
    }
    parameters{
        choice(name:'VERSION',choices:['1.1.0','1.2.0','1.3.0'],description:'version of the code')
        booleanParam(name: 'executeTests',defaultValue: true,description:'tc validity')
    }
    stages{
        stage("COMPILE"){
          
            steps{
                script{
                    echo "Compiling the code"
                    sh 'mvn compile'
                }
            }
        }
        stage("UNITTEST"){
           
            when{
                expression{
                    params.executeTests == true
                }
            }
            steps{
                script{
                    echo "Testing the code"
                    sh 'mvn test'
                }
            }
            post{
                always{
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
         stage("PACKAGE"){
           
           
            steps{
                script{
                    echo "Packaging the code"
                    sh 'mvn package'
                }
            }
        }
         stage("BUILD THE DOCKER IMAGE"){
         
            
            steps{
                script{
                    echo "BUILDING THE DOCKER IMAGE"
                    echo "Deploying version ${params.VERSION}"
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh 'sudo systemctl start docker'
                        sh 'sudo docker build -t doppal/myownimage:$BUILD_NUMBER .'
                        sh 'sudo docker login -u $USER -p $PASS'
                        sh 'sudo docker push doppal/myownimage:$BUILD_NUMBER'
                }
            }
        }
         }
        stage("DEPLOYONec2"){
            steps{
                script{
                    echo "Deploying the app"
                    echo "Deploying version ${params.VERSION}"
                    sshagent(['deploy-server-key']) {
                        withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "ssh  -o StrictHostKeyChecking=no ec2-user@3.133.146.157 'sudo amazon-linux-extras install docker -y'"
                        sh "ssh  -o StrictHostKeyChecking=no ec2-user@3.133.146.157 'sudo systemctl start docker'"
                        sh "ssh  -o StrictHostKeyChecking=no ec2-user@3.133.146.157 'sudo sudo docker login -u $USER -p $PASS'"
                        sh "ssh  -o StrictHostKeyChecking=no ec2-user@3.133.146.157 'sudo docker run -itd -P doppal/myownimage:$BUILD_NUMBER'"
}
                }
            }
    }
}
    }
}