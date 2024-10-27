resource "aws_ecr_repository" "webapp" {
  name                 = "webapp"
  image_tag_mutability = "MUTABLE"
}