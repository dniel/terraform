resource "aws_iam_policy" "allow_kms_decrypt_encrypt" {
  name        = "allow_kms_decrypt_encrypt"
  description = "A policy to provide access to encrypt/decrypt with KMS."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Action": [
          "kms:Decrypt",
          "kms:Encrypt"
        ],
        "Resource": "arn:aws:kms:*:198596758466:key/*"
      }
    ]
  })
}
resource "aws_iam_user_policy_attachment" "allow_kms_decrypt_encrypt_user_policy_attach" {
  user       = aws_iam_user.pipeline_job_user.name
  policy_arn = aws_iam_policy.allow_kms_decrypt_encrypt.arn
}

data "aws_iam_policy" "SecretsManagerReadWrite" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}
data "aws_iam_policy" "IAMFullAccess" {
  arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}
data "aws_iam_policy" "AmazonS3FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
data "aws_iam_policy" "AmazonSQSFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}
data "aws_iam_policy" "AmazonSNSFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}
data "aws_iam_policy" "AmazonSSMFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}
data "aws_iam_policy" "AmazonRoute53FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}
data "aws_iam_policy" "AdministratorAccess" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
resource "aws_iam_user_policy_attachment" "allow_administrator-access_user_policy_attach" {
  user       = aws_iam_user.pipeline_job_user.name
  policy_arn = data.aws_iam_policy.AdministratorAccess.arn
}

resource "aws_iam_user_policy_attachment" "allow_iam_fullaccess_user_policy_attach" {
  user       = aws_iam_user.pipeline_job_user.name
  policy_arn = data.aws_iam_policy.IAMFullAccess.arn
}
resource "aws_iam_user_policy_attachment" "allow_secretsmanager_readwrite_user_policy_attach" {
  user       = aws_iam_user.pipeline_job_user.name
  policy_arn = data.aws_iam_policy.SecretsManagerReadWrite.arn
}
resource "aws_iam_user_policy_attachment" "allow_ssm_fullaccess_user_policy_attach" {
  user       = aws_iam_user.pipeline_job_user.name
  policy_arn = data.aws_iam_policy.AmazonSSMFullAccess.arn
}
resource "aws_iam_user_policy_attachment" "allow_s3_fullaccess_user_policy_attach" {
  user       = aws_iam_user.pipeline_job_user.name
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess.arn
}
resource "aws_iam_user_policy_attachment" "allow_sns_fullaccess_user_policy_attach" {
  user       = aws_iam_user.pipeline_job_user.name
  policy_arn = data.aws_iam_policy.AmazonSNSFullAccess.arn
}
resource "aws_iam_user_policy_attachment" "allow_sqs_fullaccess_user_policy_attach" {
  user       = aws_iam_user.pipeline_job_user.name
  policy_arn = data.aws_iam_policy.AmazonSQSFullAccess.arn
}
resource "aws_iam_user_policy_attachment" "allow_route53_fullaccess_user_policy_attach" {
  user       = aws_iam_user.pipeline_job_user.name
  policy_arn = data.aws_iam_policy.AmazonRoute53FullAccess.arn
}
