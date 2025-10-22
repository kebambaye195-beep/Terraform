# 🔸 EC2 Instance
resource "aws_instance" "lab_ec2" {
  ami                    = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 (us-west-2)
  instance_type          = var.instance_type
  iam_instance_profile   = "LabInstanceProfile"
  key_name               = var.ec2_key_name

  tags = {
    Name = "sandbox-ec2"
  }
}

# 🔸 DynamoDB Table
resource "aws_dynamodb_table" "lab_table" {
  name           = "TestTable"
  billing_mode   = "PAY_PER_REQUEST"

  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  tags = {
    Environment = "Sandbox"
    Project     = "TerraformTest"
  }
}

