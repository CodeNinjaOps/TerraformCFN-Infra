terraform {
    backend "s3" {
        bucket = "tf-state-001"
        key = "development/terraform_state"
        region = "us-east-1"    
}
}