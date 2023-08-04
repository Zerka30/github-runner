FROM ubuntu:latest as base
FROM base as builder

# Define env variables
ENV RUNNER_NAME="docker-runner"
ENV WORKDIR="/actions-runner"
ENV RUNNER_VERSION="2.307.1"

# Update image and install curl
RUN apt-get update && apt-get install -y curl

# Define /actions-runner has workdir
WORKDIR ${WORKDIR}

# Install Dotnet Core 6.0 dependancies
RUN apt-get install -y libicu-dev

# Donwload and extract Github runner
RUN curl -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -o actions-runner.tar.gz && \
    tar xzf actions-runner.tar.gz && \
    rm actions-runner.tar.gz

# Runner Image
FROM builder

# Label
LABEL maintainer="Zerka30"
LABEL email="contact@zerka.dev"
LABEL RunnerVersion=${RUNNER_VERSION}

# Define /actions-runner has workdir
WORKDIR "${WORKDIR}"

# Create user "github"
RUN useradd -ms /bin/bash github

# Set permissions to github user
RUN chown -R github:github "${WORKDIR}"

ADD ./entry.sh .

# Set execution permissions
RUN chmod +x entry.sh

USER github

ENTRYPOINT ["./entry.sh"]