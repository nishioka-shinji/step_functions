resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "my-state-machine"
  role_arn = "arn:aws:iam::678750362522:role/service-role/StepFunctions-H4BStateMachine-role-5fd2fe96"

  definition = <<EOF
{
  "Comment": "A description of my state machine",
  "StartAt": "DynamoDB GetItem",
  "States": {
    "DynamoDB GetItem": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:dynamodb:getItem",
      "Parameters": {
        "TableName": "Article",
        "Key": {
          "ArticleID": {
            "S.$": "$.ArticleID"
          }
        }
      },
      "Next": "Choice - Item is present"
    },
    "Choice - Item is present": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.Item",
          "IsPresent": true,
          "Next": "Success"
        }
      ],
      "Default": "Fail"
    },
    "Success": {
      "Type": "Succeed"
    },
    "Fail": {
      "Type": "Fail"
    }
  },
  "TimeoutSeconds": 30
}
EOF
}