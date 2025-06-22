variable "aws_region" {
  description = "The AWS region to deploy the resources to"
  type        = string
}

variable "iam_policy_names" {
  description = "List of AWS managed IAM policy names to attach to the GitHub Actions role"
  type        = list(string)
}