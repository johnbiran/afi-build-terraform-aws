locals {
  product_domain = "apr"
  service_name   = "aprafsa"
  codebuild_role_arn   = "arn:aws:iam::517530806209:role/service-role/codebuild.amazonaws.com/ServiceRoleForCodebuild_apr-container-d2696dc94ba05be7"
  codebuild_role_name  = "ServiceRoleForCodebuild_apr-container-d2696dc94ba05be7"
  code_repo      =  "accom-affiliate-search-application-service" # "hotel:accom-affiliate-search-application-service"

  buildspec = <<EOF
version: 0.2
#                            _ooOoo_
#                           o8888888o
#                           88" . "88
#                           (| -_- |)
#                            O\ = /O
#                        ____/`---'\____
#                      .   ' \\| |// `.
#                       / \\||| : |||// \
#                     / _||||| -:- |||||- \
#                       | | \\\ - /// | |
#                     | \_| ''\---/'' | |
#                      \ .-\__ `-` ___/-. /
#                   ___`. .' /--.--\ `. . __
#                ."" '< `.___\_<|>_/___.' >'"".
#               | | : `- \`.;`\ _ /`;.`/ - ` : | |
#                 \ \ `-. \_ __\ /__ _/ .-` / /
#         ======`-.____`-.___\_____/___.-`____.-'======
#                            `=---='
#                           Build Pass

env:
  variables: 
    SERVICE_DOCKER_IMAGE: "${local.service_name}-docker-image"
    AWS_ACCOUNT: "517530806209"
    BEIARTF_CODEBUILD_ROLE_ARN: "arn:aws:iam::517530806209:role/beiartf-reader-ff59caa9b4b093d9"
    
phases:
  install:
    runtime-versions:
      java: openjdk8
      docker: 18
  pre_build:
    commands:
      - $(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)
      - wget -N https://raw.githubusercontent.com/traveloka/aws-sudo/master/aws-sudo.sh
      - chmod +x aws-sudo.sh
      - currentDir=`pwd`
      - export PATH=$PATH:$currentDir
  build:
    commands: 
      - pwd  
      - echo Execute gradle task
      - echo aws list credential to get details on the IAM credentials
      - aws configure list
      - echo aws sts get-caller-identity
      - aws sts get-caller-identity
      - echo CODEBUILD_SOURCE_VERSION
      - echo $CODEBUILD_SOURCE_VERSION
      - echo CODEBUILD_RESOLVED_SOURCE_VERSION
      - echo $CODEBUILD_RESOLVED_SOURCE_VERSION
      # - commitId=`expr match $CODEBUILD_SOURCE_VERSION '.*\(.*^{.*}\)'`
      - commitIdShortForm=`expr substr $CODEBUILD_RESOLVED_SOURCE_VERSION 1 11`
      - echo commitIdShortForm   
      - echo $commitIdShortForm   
      # Docker image tag default generate 9 digit based on commit id
      - dockerImageTag=`expr substr $CODEBUILD_RESOLVED_SOURCE_VERSION 1 9`
      - echo dockerImageTag
      - echo $dockerImageTag 
      - dockerRepository="$AWS_ACCOUNT.dkr.ecr.ap-southeast-1.amazonaws.com/$SERVICE_DOCKER_IMAGE:"$commitIdShortForm
      - echo $dockerRepository
      # - $beiartfRefresh
      - echo CODEBUILD_BUILD_ARN
      - echo $CODEBUILD_BUILD_ARN 
      - $(aws-sudo.sh -d 3600 $BEIARTF_CODEBUILD_ROLE_ARN | sed s/AWS_/BEIARTF_/g)
      - echo $(aws-sudo.sh -d 3600 $BEIARTF_CODEBUILD_ROLE_ARN | sed s/AWS_/BEIARTF_/g)
      # - ./gradlew hotel:accom-affiliate-search-application-service:buildDocker --stacktrace --scan
      - ./gradlew ${local.code_repo}:buildDocker --stacktrace --scan
      - echo Build started on `date`
      - echo Building the Docker image...          
      # - docker build -t aprafsa-docker-image:latest .
      - echo CODEBUILD_SOURCE_VERSION
      - echo Build succeed ! 
      - echo printout docker images
      - docker images
      - echo origin docker repo name
      - echo $AWS_ACCOUNT.dkr.ecr.ap-southeast-1.amazonaws.com/$SERVICE_DOCKER_IMAGE:$dockerImageTag
      - docker tag $AWS_ACCOUNT.dkr.ecr.ap-southeast-1.amazonaws.com/$SERVICE_DOCKER_IMAGE:latest $dockerRepository
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push $dockerRepository
      
cache:
  paths:
    - aws-sudo.sh  
EOF
}
}
