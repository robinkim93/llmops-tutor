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
        Action = "sts:AssumeRole"          # Security Token Service에 이 역할 빌려쓰기 요청하도록 함 (Effect, principal, action을 sts가 확인하고 임시 키를 람다에 발급)
        Effect = "Allow"                   # 허락
        Principal = {                      # 빌려 쓸 서비스 또는 계정을 작성함
          Service = "lambda.amazonaws.com" # 이 프로젝트에서는 람다가 사용해야하기 때문에 람다를 써줌
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "llmops_tutor_lambda_role_policy" {     # 어떤 역할에 어떤 정책을 붙일지 작성함 
  role       = aws_iam_role.llmops_tutor_lambda_role.name                         # 어떤 역할에
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" # 어떤 것을 할 수 있는지 정의된 정책을 작성
}

resource "aws_cloudwatch_log_group" "llmops_tutor_lambda_log_group" {
  name              = "/aws/lambda/llmops-tutor-lambda-function"
  retention_in_days = 7
}
