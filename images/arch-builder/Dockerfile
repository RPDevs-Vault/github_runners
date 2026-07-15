# Kodi-Fleet Arch Linux Builder Runner (Multilib Support)
FROM archlinux:latest

# Enable multilib repository for 32-bit compilation support
RUN echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf && \
    pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel \
    multilib-devel \
    git \
    curl \
    jq \
    sudo \
    icu \
    openssl \
    zlib \
    krb5 \
    nodejs \
    npm \
    python \
    python-pip \
    zip \
    unzip \
    tar \
    rsync \
    patch \
    wget \
    cmake \
    ninja \
    gperftools \
    && pacman -Scc --noconfirm

# Add a non-root user for the runner
RUN useradd -m runner && \
    usermod -aG wheel runner && \
    echo "%wheel ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/runner
ARG RUNNER_VERSION=2.335.1
RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Pre-create directories that Docker would otherwise create as root for bind-mounts.
RUN mkdir -p /home/runner/.cache /home/runner/_work /home/runner/go && \
    chown -R runner:runner /home/runner

# Environment Setup for Dynamic SDKs
ENV ANDROID_HOME=/home/runner/shared/appdata/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin

COPY entrypoint.sh /home/runner/entrypoint.sh
RUN chmod +x /home/runner/entrypoint.sh

USER runner
ENTRYPOINT ["/home/runner/entrypoint.sh"]
