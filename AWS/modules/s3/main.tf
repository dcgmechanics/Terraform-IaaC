resource "aws_s3_bucket" "s3-bucket" {
    bucket = "${var.bucket_name}"

    tags = {
        Name = "${var.project-name}-${var.infra_env}-s3-bucket"
        Project     = "${var.project-name}.com"
        Environment = var.infra_env
        ManagedBy   = "dcgmechanics"
    }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_ownership_controls]

  bucket = aws_s3_bucket.s3-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "s3_ownership_controls" {
  bucket = aws_s3_bucket.s3-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}