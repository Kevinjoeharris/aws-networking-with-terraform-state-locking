#S3 Bucket
resource "aws_s3_bucket" "state_s3locking" {
    bucket = "aws-networking-s3-bucket-1"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_for_S3" {
  bucket = aws_s3_bucket.state_s3locking.id

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
  #lifecycle {
  #prevent_destroy = true  #This line prevents state file from deleting. Since it is practice env, I am commenting it.
  #}
}

#DyanamoDB
resource "aws_dynamodb_table" "db_state_locking" {
  name = "db_state_locking"
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
  name = "LockID"
  type = "S"
}
}

#Restrict public access
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.state_s3locking.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

#Backend
terraform {
  backend "s3" {
    bucket = "aws-networking-s3-bucket-1"
    key = "terraform/state-file"
    dynamodb_table = "db_state_locking"
    region = "us-east-1"
  }
}