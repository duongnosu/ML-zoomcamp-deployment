#!/usr/bin/env bash
set -euo pipefail

REGION=ap-southeast-2
ECR_URL=350316957153.dkr.ecr.${REGION}.amazonaws.com
REPO_NAME=churn-prediction-lambda
REPO_URL=${ECR_URL}/${REPO_NAME}

LOCAL_IMAGE=churn-lambda
TAG=v1
REMOTE_IMAGE=${REPO_URL}:${TAG}

# Lambda needs a single-arch Docker manifest (no OCI index / provenance attestation)
docker build --platform linux/amd64 --provenance=false -t ${LOCAL_IMAGE} .

# Create the repository if it doesn't exist yet
aws ecr describe-repositories --repository-names ${REPO_NAME} --region ${REGION} >/dev/null 2>&1 \
  || aws ecr create-repository --repository-name ${REPO_NAME} --region ${REGION}

aws ecr get-login-password --region ${REGION} \
  | docker login --username AWS --password-stdin ${ECR_URL}

docker tag ${LOCAL_IMAGE} ${REMOTE_IMAGE}
docker push ${REMOTE_IMAGE}

echo "Pushed ${REMOTE_IMAGE}"
