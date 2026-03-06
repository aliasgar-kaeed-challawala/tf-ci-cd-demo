provider "aws"{
    region = "us-east-1"
}

#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "my-bucket"{
    bucket = "akc-s3-tf-bucket"
}

resource "aws_s3_bucket_ownership_controls" "my-controls"{
    bucket = aws_s3_bucket.my-bucket.id
    rule{
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_acl" "my-acl"{
    depends_on = [aws_s3_bucket_ownership_controls.my-controls]
    bucket = aws_s3_bucket.my-bucket.id
    acl = "private"
}

resource "aws_s3_bucket_public_access_block" "my-block"{
    bucket = aws_s3_bucket.my-bucket.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "my-bucket-versioning"{
    bucket = aws_s3_bucket.my-bucket.id
    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_kms_key" "my-key" {

    description = "This key is used to encrypt objects"
    enable_key_rotation = true
    deletion_window_in_days = 7
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my-bucket-config" {
    bucket = aws_s3_bucket.my-bucket.id
    rule{
        apply_server_side_encryption_by_default {
          kms_master_key_id = aws_kms_key.my-key.arn
          sse_algorithm = "aws:kms"
        }
    }
}