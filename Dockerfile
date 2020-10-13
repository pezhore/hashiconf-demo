FROM ventx/alpine

ARG VSPHERE_SERVER
ARG VSPHERE_USER
ARG VSPHERE_PASSWORD
ARG VAULT_ADDR
ARG VAULT_TOKEN
ARG VAULT_TLS_SKIP_VERIFY
ARG ANSIBLE_HOST_KEY_CHECKING

ENV VSPHERE_SERVER=${VSPHERE_SERVER}
ENV VSPHERE_USER=${VSPHERE_USER}
ENV VSPHERE_PASSWORD=${VSPHERE_PASSWORD}
ENV VAULT_ADDR=${VAULT_ADDR}
ENV VAULT_TOKEN=${VAULT_TOKEN}
ENV VAULT_TLS_SKIP_VERIFY=${VAULT_TLS_SKIP_VERIFY}
ENV ANSIBLE_HOST_KEY_CHECKING=${ANSIBLE_HOST_KEY_CHECKING}}


ENV TERRAFORM_VERSION 0.12.7
ENV VSPHERE_SERVER=$

RUN set -eux \
    && apk --update --no-cache add gcc libc6-compat git openssh-client python py-pip python3 sshpass && pip install awscli

RUN set -eux && \
	apk add --no-cache \
		bc \
		gcc \
		libffi-dev \
		make \
		musl-dev \
		openssl-dev \
		python3 \
		python3-dev

RUN set -eux && \
    pip3 install --no-cache-dir --no-compile ansible; \
	find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

RUN set -eux && \
    cd /usr/local/bin && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

WORKDIR /work

CMD ["/bin/bash"]