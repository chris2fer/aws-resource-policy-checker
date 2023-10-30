terraform {
    backend "s3" {
        bucket = "cjd-terraform-backend"
        key    = "terraform/aws-resource-policy-checker"
        region = "us-west-2"
    }
}