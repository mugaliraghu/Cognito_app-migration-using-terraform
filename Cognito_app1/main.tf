provider "aws" {
  region = "us-east-1"
}

resource "aws_cognito_user_pool" "pool" {
  name = "mypool"
  password_policy {
    minimum_length = "8"
    require_numbers = "true"
  }
    mfa_configuration          = "OFF"

    account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
}
  
  username_attributes = ["email"]
  auto_verified_attributes = [ "email" ]
  
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject = "Account Confirmation"
    email_message = "Your confirmation code is {####}"
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }
  
  lambda_config {
   post_confirmation                   = "${aws_lambda_function.test_lambda.arn}"

  }

}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "new-domain-name"
  user_pool_id = aws_cognito_user_pool.pool.id

}

resource "aws_cognito_user_pool_client" "userpool_client" {
   name                                 = "client"
   generate_secret     = false
   user_pool_id = aws_cognito_user_pool.pool.id
   callback_urls      = ["http://localhost:8000/logged_in.html"]            
   logout_urls        = ["http://localhost:8000/logged_out.html"]
   allowed_oauth_flows_user_pool_client = true
   allowed_oauth_flows                  = ["code"]
   allowed_oauth_scopes                 = ["email", "openid"]
   supported_identity_providers         = ["COGNITO"] 
    explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"


    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda2"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "Program.py"
  output_path = "Program.zip"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "${data.archive_file.zip.output_path}"
  function_name = "Cognito_Trigger"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "Program.lambda_handler"
  source_code_hash = "${data.archive_file.zip.output_base64sha256}"
  runtime = "python3.9"

}

resource "aws_lambda_permission" "allow_execution_from_user_pool" {
  statement_id = "AllowExecutionFromUserPool"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal = "cognito-idp.amazonaws.com"
  source_arn = aws_cognito_user_pool.pool.arn
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-policy3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "events:PutEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
