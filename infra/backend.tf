terraform {
  backend "s3" {                                       # 상태 파일 공유 방식
    bucket       = "llmops-tutor-tfstate-381492297285" # 상태 파일 업로드 대상 s3 bucket
    key          = "infra/terraform.tfstate"           # 상태 파일을 저장할 경로
    region       = "ap-northeast-2"                    # bucket의 리전
    use_lockfile = true                                # 동시 수정 불가 설정
  }
}
