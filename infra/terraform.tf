# Terraform 프로그램과 AWS 연결 도구 (provider)의 버전을 고정하기 위해 사용
# 버전 고정을 하지 않고 나중에 terraform init을 할 경우 버전이 달라져 코드 수정이 필요해질 수 있음.

terraform {                     # Terraform 자체 설정이며, aws 자원을 생성하는 것이 아니라 Terraform이 어떻게 동작할지 설정
  required_version = "1.17.2"   # Terraform 버전 명시하여, 문법이 바뀌더라도 해당 버전을 사용하게 강제하여 수정을 최소화한다.  
  required_providers {          # provider는 Terraform과 특정 서비스(AWS, Azure, GCP)를 이어주는 프로그램임.
    aws = {                     # 현재 Terraform 코드에서 이 provider의 이름을 aws로 하겠다는 명시
      source  = "hashicorp/aws" # Terraform 공식 저장소에 있는 공식 aws provider  
      version = "~> 6.0"        # 6버전 이상 7버전 미만까지만 허용한다는 명시
    }
  }
}
