resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    # shown on aws console by default
    Name = "${local.env}-igw"
  }
}