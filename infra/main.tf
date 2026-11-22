resource "aws_ecr_repository" "llmops_tutor" {     # aws ecr repository를 llmops-tutor라는 이름으로 생성 (terraform 상)
  name                 = "llmops-tutor-repository" # 실제 repository가 가질 이름
  force_delete         = true                      # 기본적으로 aws는 repository 안에 이미지가 있으면 삭제가 안되지만 terraform destroy 시, 바로 삭제가 가능하기 위해 true로 값 설정
  image_tag_mutability = "IMMUTABLE"               # 업로드하려는 이미지들의 태그가 겹치지 않게 하는 설정. 겹치면 업로드가 안된다.
}

resource "aws_iam_role" "llmops_tutor_lambda_role" { # iam 역할을 llmops-tutor-lambda-role이라는 이름으로 생성 (terraform 상)
  name = "llmops-tutor-lambda-role"                  # 실제 iam 역할이 가질 이름
  assume_role_policy = jsonencode({                  # 이 역할을 사용할 수 있는지 정의하는 것. 신뢰 정책이라고 부름
    Version = "2012-10-17"                           # 최신 문법 버전임
    Statement = [                                    # 규칙 목록
      {
        Action = "sts:AssumeRole"            # Security Token Service에 이 역할 빌려쓰기 요청하도록 함 (Effect, principal, action을 sts가 확인하고 임시 키를 람다에 발급)
        Effect = "Allow"                     # 허락
        Principal = {                        # 빌려 쓸 서비스 또는 계정을 작성함
          Service = ["lambda.amazonaws.com"] # 이 프로젝트에서는 람다가 사용해야하기 때문에 람다를 써줌
        }
      }
    ]
  })
}

data "aws_region" "current_region" {
}

data "aws_caller_identity" "current_user" {
}

resource "aws_iam_policy" "llmops_tutor_ssm_policy" {
  name = "llmops-tutor-ssm-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameters"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ssm:${data.aws_region.current_region.region}:${data.aws_caller_identity.current_user.id}:parameter/llmops-tutor/claude_api_key",
          "arn:aws:ssm:${data.aws_region.current_region.region}:${data.aws_caller_identity.current_user.id}:parameter/llmops-tutor/llm_call_password"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "llmops_tutor_lambda_role_policy" {     # 어떤 역할에 어떤 정책을 붙일지 작성함 
  role       = aws_iam_role.llmops_tutor_lambda_role.name                         # 어떤 역할에
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" # 어떤 것을 할 수 있는지 정의된 정책을 작성
}

resource "aws_iam_role_policy_attachment" "llmops_tutor_ssm_role_policy" {
  role       = aws_iam_role.llmops_tutor_lambda_role.name
  policy_arn = aws_iam_policy.llmops_tutor_ssm_policy.arn
}

resource "aws_cloudwatch_log_group" "llmops_tutor_lambda_log_group" {
  name              = "/aws/lambda/llmops-tutor-lambda-function" # 로그 그룹 이름 (람다 함수명과 똑같이 해야 나중에 생성될 람다 함수가 로그 그룹을 정상적으로 찾아감)
  retention_in_days = 7                                          # 로그 보존 일수
}

resource "aws_lambda_function" "llmops_tutor_lambda_function" {
  function_name = "llmops-tutor-lambda-function"            # 람다 함수 이름
  role          = aws_iam_role.llmops_tutor_lambda_role.arn # 함수 실행 시 사용할 권한
  package_type  = "Image"                                   # docker기 때문에 image, 기본으로 두면 zip으로 설정됨
  image_uri     = "${aws_ecr_repository.llmops_tutor.repository_url}:${var.image_tag}"
  environment {
    variables = {
      OK_MESSAGE = "ok"
    }
  }
  architectures = ["x86_64"] # Github actions에서 빌드했기 때문에
  timeout       = 30         # 호출 시간 초과 시간 설정
  memory_size   = 512        # 메모리 크기
  depends_on = [             # 명시된 것들이 정상적으로 생성됨을 확인한 후 람다 함수를 생성함
    aws_iam_role_policy_attachment.llmops_tutor_lambda_role_policy,
    aws_iam_role_policy_attachment.llmops_tutor_ssm_role_policy,
    aws_cloudwatch_log_group.llmops_tutor_lambda_log_group
  ]
}

resource "aws_lambda_function_url" "llmops_tutor_lambda_function_url" {
  function_name      = aws_lambda_function.llmops_tutor_lambda_function.function_name # url에 접근했을 때 실행 될 함수
  authorization_type = "NONE"                                                         # 아무나 들어올 수 있도록
}

resource "aws_lambda_permission" "llmops_tutor_lambda_function_permission" {
  action                 = "lambda:InvokeFunctionUrl"                                     #
  function_name          = aws_lambda_function.llmops_tutor_lambda_function.function_name # 허용할 람다 함수
  principal              = "*"                                                            # 아무나
  function_url_auth_type = "NONE"                                                         # 아무나
}

output "llmops_tutor_lambda_function_url" { # 터미널 출력용
  description = "llmops tutor lambda function url"
  value       = aws_lambda_function_url.llmops_tutor_lambda_function_url.function_url
}


