pipeline {
agent {
    label 'fabric-cluster'
}

environment {
    NETWORK_DIR = "test-network-k8s"
    CC_NAME = "asset-transfer-basic"
}

stages {

    stage('Pre-checks') {
        steps {
            sh 'kubectl get nodes'
            sh 'docker ps'
        }
    }

    stage('Network Up') {
        steps {
            dir("${NETWORK_DIR}") {
                sh './network up'
            }
        }
    }

    stage('Create Channel') {
        steps {
            dir("${NETWORK_DIR}") {
                sh './network channel create'
            }
        }
    }

    stage('Deploy Chaincode') {
        steps {
            dir("${NETWORK_DIR}") {
                sh "./network chaincode deploy ${CC_NAME} ../asset-transfer-basic/chaincode-java"
            }
        }
    }

    stage('Invoke Transaction') {
        steps {
            dir("${NETWORK_DIR}") {
                sh """
                ./network chaincode invoke ${CC_NAME} '{"Args":["InitLedger"]}'
                ./network chaincode query ${CC_NAME} '{"Args":["ReadAsset","asset1"]}'
                """
            }
        }
    }
    
    stage('Query Transaction') {
        steps {
            dir("${NETWORK_DIR}") {
                sh """
                ./network chaincode query ${CC_NAME} '{"Args":["ReadAsset","asset1"]}'
                """
            }
        }
    }
}

post {
    success {
        echo '✅ Fabric pipeline completed successfully'
    }
    failure {
        echo '❌ Fabric pipeline failed'
    }
}

}

