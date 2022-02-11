#---------------------------------------------------------------------------
# ADD THE API GATEWAY IAM PERMISSIONS AT THE REGION ACCOUNT LEVEL
#---------------------------------------------------------------------------
resource "aws_api_gateway_account" "apigw_teste" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch_s3.arn
}

#---------------------------------------------------------------------------
# CREATE THE IAM ROLE API GATEWAY CAN ASSUME
#---------------------------------------------------------------------------
resource "aws_iam_role" "cloudwatch_s3" {
  name               = "ApiGw-TESTE-Cloudwatch-S3"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_iam_role.json
}

data "aws_iam_policy_document" "api_gateway_iam_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

#---------------------------------------------------------------------------
# ATTACH CLOUDWATCH PERMISSIONS TO THE IAM ROLE
#---------------------------------------------------------------------------
resource "aws_iam_role_policy" "cloudwatch" {
  name   = "ApiGw-TESTE-Cloudwatch"
  role   = aws_iam_role.cloudwatch_s3.id
  policy = data.aws_iam_policy_document.cloudwatch_logs.json
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]
    resources = ["*"]
  }
}

#---------------------------------------------------------------------------
# ATTACH S3 PERMISSIONS TO THE IAM ROLE
#---------------------------------------------------------------------------
resource "aws_iam_role_policy" "s3" {
  name   = "ApiGw-TESTE-s3"
  role   = aws_iam_role.cloudwatch_s3.id
  policy = data.aws_iam_policy_document.s3_access.json
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject*",
      "s3:ListBucket",
      "s3:PutObject*",
      "s3:DeleteObject*"
    ]
    resources = [
      module.bucket_api_teste.this_s3_bucket_arn,
      "${module.bucket_api_teste.this_s3_bucket_arn}/*"]
  }
}

#---------------------------------------------------------------------------
# CREATE S3 POLICIES
#---------------------------------------------------------------------------
resource "aws_iam_policy" "s3_access" {
  name        = "ApiGw-TESTE-s3-policy"
  policy      = data.aws_iam_policy_document.s3_access.json
}

resource "aws_iam_policy_attachment" "s3_access_attach_policy" {
  name       = "ApiGw-TESTE-s3-policy"
  roles      = [aws_iam_role.cloudwatch_s3.name]
  policy_arn = aws_iam_policy.s3_access.arn
}