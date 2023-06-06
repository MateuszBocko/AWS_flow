provider "aws" {
  region = "eu-central-1"
}

data "template_file" "policy" {
  template = "${file("private_key.txt")}"
}

output "test" {
  value = data.template_file.policy.rendered
}