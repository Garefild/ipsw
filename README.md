# IPSW Daemon - Blacktop iOS Symbols Scanner

A containerized service for scanning and managing iOS IPSW (iPhone Software) files using the **Blacktop ipswd** tool. 
This service analyzes iPhone firmware files to extract and index symbol information for reverse engineering and analysis purposes.

## Overview

IPSW (iPhone Software) files are compressed archives containing iOS firmware. This tool leverages Blacktop's `ipswd` daemon to:

- **Scan** IPSW files to extract symbol tables and binary metadata
- **Rescan** IPSW files to update indexed symbol information
- **Store** analyzed data in a PostgreSQL database
- **Provide** REST API endpoints for querying symbol information

## Prerequisites

- Docker and Docker Compose
- At least 50GB of free disk space (for IPSW files)
- IPSW files placed in the `./data` directory

## Quick Start

### 1. Prepare IPSW Files

Place your IPSW files in the `./data` directory:
```
bash
mkdir -p data
# Copy your .ipsw files here
cp /path/to/iPhone15,4_26.1_23B85_Restore.ipsw data/
```
### 2. Start the Services
```
bash
docker-compose up -d
```
This will start:
- **PostgreSQL** database (port 5432)
- **ipswd daemon** (port 3993)

### 3. Verify Services are Running
```
bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f ipswd

# Check ping to ipswd
http://localhost:3993/v1/_ping
```
## API Usage

The daemon runs on `http://localhost:3993` by default.

### Scan an IPSW File

Scan a new IPSW file and extract symbol information:
```
bash
curl -X POST 'http://localhost:3993/v1/syms/scan?path=/data/iPhone15,4_26.1_23B85_Restore.ipsw'
```
**Parameters:**
- `path`: Full path to the IPSW file inside the container

**Response:** Returns scan progress and indexed symbols count

### Rescan an IPSW File

Update symbol information for an already-scanned IPSW file:
```
bash
curl -X PUT 'http://localhost:3993/v1/syms/rescan?path=/data/iPhone15,4_26.1_23B85_Restore.ipsw'
```
**Parameters:**
- `path`: Full path to the IPSW file inside the container

## Configuration

Configuration is managed through environment variables in `docker-compose.yml`:

### Daemon Settings
- `DAEMON_HOST`: Server bind address (default: `0.0.0.0`)
- `DAEMON_PORT`: Server port (default: `3993`)
- `DAEMON_DEBUG`: Enable debug logging (default: `true`)

### Database Settings
- `POSTGRES_HOST`: Database hostname (default: `postgres`)
- `POSTGRES_PORT`: Database port (default: `5432`)
- `POSTGRES_DB`: Database name (default: `ipsdb`)
- `POSTGRES_USER`: Database user (default: `ipsuser`)
- `POSTGRES_PASSWORD`: Database password (default: `ipspass`)

## File Structure
```

.
├── data/                 # IPSW files storage
├── src/
│   ├── config.yml        # ipswd daemon configuration
│   └── entrypoint.sh     # Container startup script
├── docker-compose.yml    # Service orchestration
├── Dockerfile           # ipswd image configuration
└── README.md            # This file
```
## Stopping the Services

```bash
# Stop all containers
docker-compose down

# Stop and remove volumes (warning: deletes database data)
docker-compose down -v
```

## Start ipswd with SQLite backend

```bash

docker run -it \
    --privileged \
    --shm-size=8g \
    -p 3993:3993 \
    -v ./data:/data \
    --entrypoint /bin/bash \
    blacktop/ipswd
```

```yml
daemon:
    host: 0.0.0.0
    port: 3993
    debug: true
    # logficat le: /db/ipswd.log

database:
    driver: sqlite
    path: /data/data.db
```

## Troubleshooting

### Connection Refused
- Ensure Docker Compose services are running: `docker-compose ps`
- Check if port 3993 is already in use

### Scan Fails
- Verify the IPSW file path is correct and accessible
- Check file permissions: `ls -la data/`
- View daemon logs: `docker-compose logs ipswd`

### Database Connection Issues
- Ensure PostgreSQL is running: `docker-compose logs postgres`
- Verify database credentials in `docker-compose.yml`

## About Blacktop ipswd

**ipswd** is a specialized tool by Blacktop for iOS / macOS:

- Automatically extracts symbol tables from iOS binaries
- Indexes symbols in a queryable database
- Supports multiple iOS versions and device models
- RESTful API for integration with analysis tools

More information: [Blacktop ipsw](https://blacktop.github.io/ipsw/)\
Api: [Blacktop ipsw api](https://blacktop.github.io/ipsw/api)

## License

This project uses the Blacktop ipswd tool. 
Refer to the [Blacktop repository](https://github.com/blacktop/ipsw) for licensing information.
