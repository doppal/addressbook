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
         stage("Provision ec2-server with TF"){
             steps{
                 script{
                     dir('terraform'){
                         sh 'terraform init'
                         sh 'terraform apply --auto-approve'
                         EC2_PUBLIC_IP = sh(
                             "terraform output ec2-ip",
                             returnStdout: true
                         ).trim()
                     }
                 }
             }
         }
        stage("DEPLOYONec2"){
            steps{
                script{
                    sleep(time: 90, unit: "SECONDS")
                    echo "ec2-instance created"
                    echo "${EC2_PUBLIC_IP}"
                    echo "Deploying on an ec2-instance created by TF"
                    echo "Deploying version ${params.VERSION}"
                    sshagent(['deploy-server-key']) {
                        withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "ssh  -o StrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP} 'sudo sudo docker login -u $USER -p $PASS'"
                        sh "ssh  -o StrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP} 'sudo docker run -itd -P doppal/myownimage:$BUILD_NUMBER'"
}
                }
            }
    }
}
    }
}