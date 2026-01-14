FROM blacktop/ipswd:latest

# Set working directory
WORKDIR /server

# Install envsubst (if not already in the image)
RUN apt-get update && apt-get install -y gettext && rm -rf /var/lib/apt/lists/*

# Set environment variables for Postgres (can override in docker-compose)
ENV POSTGRES_HOST=postgres
ENV POSTGRES_PORT=5432
ENV POSTGRES_DB=ipsdb
ENV POSTGRES_USER=ipsuser
ENV POSTGRES_PASSWORD=ipspass

# Copy config and entrypoint
COPY src/config.yml /config/config.yml
COPY src/entrypoint.sh /entrypoint.sh

# Use our entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
