FROM amazonlinux:2

# Setup build environment
RUN mkdir -p /build/src && \
    yum update -y && \
    # Add required packages
    amazon-linux-extras install -y postgresql14 && \
    yum install -y awscli curl git gcc gzip jq mariadb-devel openssl-devel postgresql-devel tree tar zip && \
    # help linker to find libmysqlclient later...
    ln -s /usr/lib64/mysql/libmysqlclient.so /usr/lib64/libmysqlclient.so && \
    # Install rust with rustup
    curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal

# Build environment setting
WORKDIR /build
ENV FEATURES="sqlite,postgresql"
ENV CARGOFLAGS="--release"
ENV PATH=/root/.cargo/bin:/usr/sbin:/usr/bin:/sbin:/bin
ARG VAULTWARDEN_SHA="1f868b8d22ce15c892d8b3ef5a958a045a4fdae9"

RUN echo "Fetching vaultwarden from sha..." && \
    git clone https://github.com/dani-garcia/vaultwarden.git && \
    cd vaultwarden && \
    git checkout ${VAULTWARDEN_SHA}


ADD add_lambda_compatibility_${VAULTWARDEN_SHA}.patch /build/vaultwarden/add_lambda_compatibility.patch

RUN cd /build/vaultwarden && \
    echo "Applying patch for lambda compatibility..." && \
    git apply /build/vaultwarden/add_lambda_compatibility.patch

# Default build command
CMD \
    cd /build/vaultwarden && \
    echo "Fetching latest web vault..." && \
    # Get latest web-vault release
    curl -s -L $(curl -s https://api.github.com/repos/dani-garcia/bw_web_builds/releases/latest | \
    jq -r '.assets[] | select(.name | endswith ("tar.gz")) | .browser_download_url') | tar xz && \
    # Build vaultwarden for al2
    cargo build --features "$FEATURES" --target-dir target_al2 $CARGOFLAGS && \
    # Move built file and call it bootstrap
    mv target_al2/release/vaultwarden bootstrap && \
    # Optimizations and log linking
    strip --strip-all bootstrap && \
    size bootstrap && \
    ldd  bootstrap && \
    # Copy shared libraries (postgres, mysql)
    mkdir -p lib && \
    cp /usr/lib64/mysql/libmysqlclient.so lib/libmysqlclient.so.18 && \
    cp /usr/lib64/libpq.so lib/libpq.so.5 && \
    zip -9 -r bootstrap.zip bootstrap web-vault lib && \
    # Copy to /dist
    cp bootstrap.zip /dist/bootstrap.zip