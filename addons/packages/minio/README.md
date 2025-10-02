# MinIO S3 Storage

This package adds MinIO, a self-hosted S3-compatible object storage service. MinIO is used for storing archived ticket transcripts and import data.

## What's Included

- **MinIO Server**: S3-compatible object storage service with web console
- **MinIO Setup**: Automatic bucket creation and configuration

## Installation

1. Navigate to the addons directory:
   ```bash
   cd addons/packages/minio
   ```

2. Make sure your `.env` file contains the required S3 configuration:
   ```env
   S3_ACCESS=your_access_key
   S3_SECRET=your_secret_key
   S3_ARCHIVE_BUCKET=archive
   S3_DATA_IMPORT_BUCKET=data-import
   S3_TRANSCRIPT_IMPORT_BUCKET=transcript-import
   S3_ENDPOINT=minio:9000
   S3_SECURE=false
   ```

3. Start the MinIO services:
   ```bash
   docker compose up -d
   ```

## Access

- **MinIO Console**: http://localhost:9001
  - Login with the credentials from `S3_ACCESS` and `S3_SECRET`

- **MinIO API**: http://localhost:9000
  - Used by the bot services for S3 operations

## Configuration

The setup container automatically creates the required buckets:
- Archive bucket (for ticket transcripts)
- Data import bucket
- Transcript import bucket

All buckets are set to public read access by default.

## Notes

- MinIO data is stored in the `miniodata` directory relative to the main docker-compose.yaml location
- The MinIO setup container runs once to create buckets and then exits
- If you need to recreate buckets, you can run `docker compose up minio-setup` again
