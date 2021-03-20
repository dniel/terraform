{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "route53:ChangeResourceRecordSets"
        ],
        "Resource": "arn:aws:route53:::hostedzone/${hosted_zone}"
    }
  , {
        "Effect": "Allow",
        "Action": [
            "route53:ListResourceRecordSets"
        ],
        "Resource": "arn:aws:route53:::hostedzone/${hosted_zone}"
    }, {
        "Effect": "Allow",
        "Action": [
            "route53:GetChange"
        ],
        "Resource": "arn:aws:route53:::change/*"
    }, {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}