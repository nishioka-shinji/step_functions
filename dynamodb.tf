resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "Article"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ArticleID"

  attribute {
    name = "ArticleID"
    type = "S"
  }
}

# オートスケーリング最小/最大キャパシティーユニット設定
resource "aws_appautoscaling_target" "dynamodb_table_read_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "table/${aws_dynamodb_table.basic-dynamodb-table.id}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_target" "dynamodb_table_write_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "table/${aws_dynamodb_table.basic-dynamodb-table.id}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

# オートスケーリングのON/OFF・ターゲット使用率
resource "aws_appautoscaling_policy" "dynamodb_table_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70
  }
}

resource "aws_appautoscaling_policy" "dynamodb_table_write_policy" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_write_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_write_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 70
  }
}

# テーブルアイテム
resource "aws_dynamodb_table_item" "items" {
  for_each = {
    item1 = {
      index     = "0001"
      something = "説明0001"
    }
    item2 = {
      index     = "0002"
      something = "説明0002"
    }
  }

  table_name = aws_dynamodb_table.basic-dynamodb-table.name
  hash_key   = aws_dynamodb_table.basic-dynamodb-table.hash_key

  item = <<EOF
{
  "${aws_dynamodb_table.basic-dynamodb-table.hash_key}": {"S": "${each.value.index}"},
  "detail": {"S": "${each.value.something}"}
}
EOF
}