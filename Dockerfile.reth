FROM ghcr.io/paradigmxyz/op-reth:v1.9.3

RUN apt update && apt install curl zstd -y
# Copy the check_sync_status.sh script into the container
COPY download-migration-files.sh /usr/local/bin/download-migration-files.sh

# Make the script executable
RUN chmod +x /usr/local/bin/download-migration-files.sh

ENTRYPOINT ["/usr/local/bin/download-migration-files.sh"]