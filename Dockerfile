FROM debian:bookworm-slim

# Install inotify-tools for file watching and download zola
RUN apt-get update && apt-get install -y --no-install-recommends \
    inotify-tools \
    ca-certificates \
    curl \
    && curl -sL https://github.com/getzola/zola/releases/download/v0.19.2/zola-v0.19.2-x86_64-unknown-linux-gnu.tar.gz | tar xz -C /usr/local/bin \
    && apt-get remove -y curl \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /site

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
