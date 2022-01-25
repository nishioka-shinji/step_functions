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
      something = "AWS Step Functions は、デベロッパーが分散アプリケーションの構築、IT およびビジネスプロセスの自動化、AWS のサービスを利用したデータと機械学習のパイプラインの構築に使用するローコードのビジュアルワークフローサービスです。ワークフローは、障害、再試行、並列化、サービス統合、可観測性などを管理するため、デベロッパーはより価値の高いビジネスロジックに集中することができます。"
    }
    item2 = {
      index     = "0002"
      something = "Amazon DynamoDB は、ハイパフォーマンスなアプリケーションをあらゆる規模で実行するために設計された、フルマネージド、サーバーレスの key-value NoSQL データベースです。DynamoDB は、内蔵セキュリティ、継続的なバックアップ、自動化されたマルチリージョンでのレプリケーション、インメモリキャッシング、データエクスポートツールを提供します。"
    }
  }

  table_name = aws_dynamodb_table.basic-dynamodb-table.name
  hash_key   = aws_dynamodb_table.basic-dynamodb-table.hash_key

  item = <<EOF
{
  "${aws_dynamodb_table.basic-dynamodb-table.hash_key}": {"S": "${each.value.index}"},
  "Detail": {"S": "${each.value.something}"}
}
EOF
}