# Create an IAM OpenID Connect provider (idP) for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b343e59a7684ecb4ae"]
}

# Create an IAM role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "GithubActionsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:basrihsn/rsschool-devops-course-tasks:*"
          },
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attach the policies to the GitHub Actions role
resource "aws_iam_role_policy_attachment" "github_actions_policies" {
  for_each = toset(var.iam_policy_names)

  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}