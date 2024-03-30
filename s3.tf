# ==================================
# s3 bucket
# ==================================
resource "aws_s3_bucket" "s3_website_bucket" {
  bucket_prefix = "${var.user}-${var.project}-s3-website-bucket"
}

resource "aws_s3_bucket_website_configuration" "s3_website_config" {
  bucket = aws_s3_bucket.s3_website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# ==================================
# s3 objects
# ==================================
resource "aws_s3_object" "index_page" {
  bucket       = aws_s3_bucket.s3_website_bucket.id
  key          = "index.html"
  source       = "web_pages/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error_page" {
  bucket       = aws_s3_bucket.s3_website_bucket.id
  key          = "error.html"
  source       = "web_pages/error.html"
  content_type = "text/html"
}

# ==================================
# s3 bucket policy
# ==================================
resource "aws_s3_bucket_policy" "s3_website_bucket_policy" {
  bucket = aws_s3_bucket.s3_website_bucket.id
  policy = data.aws_iam_policy_document.s3_website_bucket_policy_document.json
}

data "aws_iam_policy_document" "s3_website_bucket_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_website_bucket.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}
