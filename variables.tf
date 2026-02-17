variable "availability_zone" {
    type = list 
    default = ["us-east-1a","us-east-1b"]
}

variable "region" {
    default = "us-east-1"
    type = "string"
    description = "AWS Region"
}