
#--------------------------------------------------------------------------------------------------
# Create Bucket
#--------------------------------------------------------------------------------------------------
resource "random_id" "this" {
  byte_length = 4
}

module "bucket_api_teste" {
  source = "git::github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v1.21.0"

  bucket = "bucket-api-gw-teste-anna-${random_id.this.hex}"
  acl    = "private"

  versioning = {
    enabled = false
  }

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
