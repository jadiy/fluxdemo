node {
  workdir="/data/workdir"
  imageurl="192.168.11.14:5000"
  try{
    stage ('CI'){
        script {
          Init();
          if ("${BUILD_PROCESS}" == "init"){
            InitBuild();
          }
          DockerBuild();
          DockerPush();
          Deploy();
        }
    }
    println("##### This operation completed successfully! #####")
    }catch (Exception e) {
      println("##### ERROR Exception: ${e} #####")
    }
}



def Init(){
    if (!fileExists("${workdir}")) {
       sh "mkdir -p ${workdir}"
       dir ("${workdir}") {
           def repositoryUrl = scm.userRemoteConfigs[0].url
           sh "git init"
           sh "git remote add origin ${repositoryUrl}"
           sh "git checkout -b master"
           sh "git pull origin master"
       }
    } else {
       dir ("${workdir}") {
           sh "git pull origin master"
       }
    }
}

def InitBuild(){
    dir ("${workdir}"){
        sh "DOCKER_BUILDKIT=1 docker build -t ruoyi-init -f buildkitDockerfile  ."
    }
}

def DockerBuild(){
    dir ("${workdir}/ci"){
        sh "sudo docker build -t ${DOCKER_IMAGE_NAME}:${ENV}.${BUILD_NUMBER} --build-arg ENV=${ENV} --build-arg buildname=${DOCKER_IMAGE_NAME} ."
    }
}

def DockerPush(){
    stage ('Docker Push') {
        sh "docker tag ${DOCKER_IMAGE_NAME}:${ENV}.${BUILD_NUMBER} ${imageurl}/${DOCKER_IMAGE_NAME}:${ENV}.${BUILD_NUMBER}"
        sh "docker push ${imageurl}/${DOCKER_IMAGE_NAME}:${ENV}.${BUILD_NUMBER}"
    }
}


def Deploy(){
    stage ('Deploy Env') {
      sh "sed -e 's#{JOB_NAME}#${DOCKER_IMAGE_NAME}#g;s#{CODE}#${imageurl}/${DOCKER_IMAGE_NAME}:${ENV}.${BUILD_NUMBER}#g;s#{ENV}#${ENV}#g' ${workdir}/cd/common-deployment.yaml > ${workdir}/cd/${DOCKER_IMAGE_NAME}-k8s-deployment.${ENV}.tmp"
      sh "kubectl apply -f ${workdir}/cd/${DOCKER_IMAGE_NAME}-k8s-deployment.${ENV}.tmp "
    }
}

