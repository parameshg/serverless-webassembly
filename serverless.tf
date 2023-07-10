terraform {
  backend "s3" {
    bucket = "aspnetcore"
    key    = "terraform-state/serverless-webassembly.tfstate"
  }
}

variable "AWS_ACCOUNT" {
  type = string
  description = "AWS_ACCOUNT"
}

variable "AWS_REGION" {
  type = string
  description = "AWS_REGION"
}

variable "AWS_ACCESS_KEY_ID" {
  type = string
  description = "AWS_ACCESS_KEY_ID"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
  description = "AWS_SECRET_ACCESS_KEY"
}

provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

# AWS S3 BUCKET #################################################################################################################################################

resource "aws_s3_bucket" "serverless-webassembly" {
  bucket                       = "serverless-webassembly"

  tags                         = {
    provisioner                = "terraform"
    executioner                = "github-actions"
    project                    = "serverless-webassembly"
    url                        = "https://github.com/parameshg/serverless-webassembly"
  }
}

resource "aws_s3_bucket_website_configuration" "serverless-webassembly" {
  bucket = aws_s3_bucket.serverless-webassembly.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "serverless-webassembly" {
  bucket = aws_s3_bucket.serverless-webassembly.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_ownership_controls" "serverless-webassembly" {
  bucket = aws_s3_bucket.serverless-webassembly.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.serverless-webassembly]
}

resource "aws_s3_bucket_public_access_block" "serverless-webassembly" {
  bucket                  = aws_s3_bucket.serverless-webassembly.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "serverless-webassembly" {
    bucket = aws_s3_bucket.serverless-webassembly.id
    acl    = "public-read"
    depends_on = [aws_s3_bucket_ownership_controls.serverless-webassembly]
}

resource "aws_s3_bucket_policy" "serverless-webassembly" {
  bucket = aws_s3_bucket.serverless-webassembly.id
  policy = data.aws_iam_policy_document.serverless-webassembly.json
  depends_on = [ aws_s3_bucket_public_access_block.serverless-webassembly ]
}

data "aws_iam_policy_document" "serverless-webassembly" {
  statement {
    principals {
        type        = "*"
        identifiers = [ "*" ]
    }
    resources = [ "arn:aws:s3:::serverless-webassembly/*" ]
    actions = [ "s3:GetObject" ]
  }
}