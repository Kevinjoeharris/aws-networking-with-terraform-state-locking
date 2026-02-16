#S3 Bucket
resource "aws_s3_bucket" "state_s3locking" {
    bucket = "state_s3locking"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_for_S3" {
  bucket = aws_s3_bucket.state-locking.id

  rule {
    apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
    }
  }
}

#Enable S3 versioning 
resource "aws_s3_bucket_versioning" "backend_s3_versioning" {
  bucket = aws_s3_bucket.state_s3locking.id
  versioning_configuration {
    status = "Enabled"
  }
}

#DyanamoDB
resource "aws_dyanamo_db" "db-state-locking" {

}