FROM alpine:3.12
MAINTAINER Daniel Engfeldt <daniel@engfeldt.net>

ENV KUBE_LATEST_VERSION v1.19.0
ENV KUBE_RUNNING_VERSION v1.19.0
ENV HELM_VERSION v2.13.1
ENV AWSCLI 1.18.160
ENV TERRAFORM_VERSION 0.13.4

RUN apk --update --no-cache add \
  bash \
  ca-certificates \
  curl \
  jq \
  git \
  openssh-client \
  python3 \
  tar \
  wget

RUN pip3 install --upgrade pip
RUN pip3 install requests awscli==${AWSCLI}

# Install Terraform
RUN cd /usr/local/bin && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install kubectl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_RUNNING_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Install helm
RUN wget -q http://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm

# Install latest kubectl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl_latest \
  && chmod +x /usr/local/bin/kubectl_latest

# Install envsubst
ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl"

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps

# add terraform files
WORKDIR /work
ADD . /work
ADD docker/entrypoint.sh /entrypoint.sh

# add terraform user and make script executable
RUN adduser -D -u 10000 terraform
RUN chown terraform /entrypoint.sh && chmod u+x /entrypoint.sh
USER terraform

ENTRYPOINT ["/entrypoint.sh"]
CMD ["help"]