variable "image_tag" {
  type        = string
  description = "Docker image tag (git commit address)"
  # sensitive   = true # 민감정보를 사용할 때 옵션을 주면 cli 출력에 해당 값이 노출되지 않음
}
