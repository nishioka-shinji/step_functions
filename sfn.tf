resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "my-state-machine"
  role_arn = "arn:aws:iam::678750362522:role/service-role/StepFunctions-H4BStateMachine-role-5fd2fe96"

  definition = <<EOF
{
  "Comment": "A description of my state machine",
  "StartAt": "Pass",
  "States": {
    "Pass": {
      "Type": "Pass",
      "End": true
    }
  },
  "TimeoutSeconds": 30
}
EOF
}