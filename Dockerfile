FROM hashicorp/terraform:1.15.6

RUN apk add --no-cache git openssh-client

WORKDIR /workspace

USER 1000

ENTRYPOINT ["terraform"]
