###########################
data "aws_vpc" "selected" {
  tags = {
    Name = "dev-mdcl-mdaas-engine" # Replace with your VPC's tag name
  }
}



# output "vpc_id" {
#   value = data.aws_vpc.selected.id
# }

data "aws_subnets" "private_networks" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
}
###########################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "foo" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "us-west-2a"
  cidr_block        = "10.0.1.0/24"
}

resource "aws_subnet" "bar" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "us-west-2b"
  cidr_block        = "10.0.2.0/24"
}


resource "aws_directory_service_directory" "bar" {
  name     = "hautran.demo.com"
  password = "SuperSecretPassw0rd"
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = aws_vpc.main.id
    subnet_ids = [aws_subnet.foo.id, aws_subnet.bar.id]
  }

  tags = {
    Project = "foo"
  }
}

############# FSX ##############
resource "aws_fsx_windows_file_system" "example" {
  active_directory_id = aws_directory_service_directory.example.id
  # kms_key_id          = aws_kms_key.example.arn # Uncomment and provide if using KMS for encryption

  storage_type        = "SSD"
  storage_capacity    = 80
  subnet_ids          = [aws_subnet.example.id]
  deployment_type     = "MULTI_AZ_1"
  throughput_capacity = 1024 ### Maximum that terraform allow is 2048

  disk_iops_configuration {
    iops = 40000
    mode = "USER_PROVISIONED"
  }

  tags = {
    Service = "Fsx-wfs-40k-iops"
  }
}

