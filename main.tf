terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.88.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "random_id" "rand-id" {
  byte_length = 8

}

resource "aws_s3_bucket" "staticweb-bucket" {
  bucket = "staticweb-bucket-${random_id.rand-id.hex}"
}
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.staticweb-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "web_page" {
  bucket = aws_s3_bucket.staticweb-bucket.id
  policy =   jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
        Sid       = "PublicReadGetObject",
        Principal = "*",
        Effect    = "Allow",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.staticweb-bucket.arn}/*",
        }
        ]
    }
  )
}
resource "aws_s3_bucket_website_configuration" "web_page" {
  bucket = aws_s3_bucket.staticweb-bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "web_page" {
  bucket       = aws_s3_bucket.staticweb-bucket.bucket
  source       = "./index.html"
  key          = "index.html"
  content_type = "text/html"
}


resource "aws_s3_object" "style_css" {
  bucket       = aws_s3_bucket.staticweb-bucket.bucket
  source       = "./style.css"
  key          = "style.css"
  content_type = "text/css"
}

output "name" {
  value = aws_s3_bucket_website_configuration.web_page.website_endpoint
}
