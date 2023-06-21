provider "aws" {
  region = "eu-central-1"
}

# create s3 bucket
resource "aws_s3_bucket" "video_trending_bucket" {
    bucket = var.s3_bucket_name
}

resource "aws_s3_object" "cities_data" {
  bucket = var.s3_bucket_name
  key = "cities"
  source = "${path.module}/my_files/cities.csv"
}

output "s3_bucket_name" {
  value = var.s3_bucket_name
}