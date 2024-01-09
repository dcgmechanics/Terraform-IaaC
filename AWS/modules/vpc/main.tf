# Create a VPC for the region associated with the AZ
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  instance_tenancy = "default"

  tags = {
    Name        = "${var.project-name}-${var.infra_env}-vpc"
    Project     = "${var.project-name}.com"
    Environment = var.infra_env
    ManagedBy   = "dcgmechanics"
  }
}
 
# Create 2 Public Subnets for each AZ within the regional VPC
resource "aws_subnet" "public_subnet1" {
 
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}a"
 
  # 2,048 IP addresses each
  cidr_block = var.public_subnet1
 
  tags = {
    Name        = "${var.project-name}-${var.infra_env}-public1-subnet"
    Project     = "${var.project-name}.com"
    Role        = "public"
    Environment = var.infra_env
    ManagedBy   = "dcgmechanics"
  }
}

resource "aws_subnet" "public_subnet2" {
 
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}b"
 
  # 2,048 IP addresses each
  cidr_block = var.public_subnet2
 
  tags = {
    Name        = "${var.project-name}-${var.infra_env}-public2-subnet"
    Project     = "${var.project-name}.com"
    Role        = "public"
    Environment = var.infra_env
    ManagedBy   = "dcgmechanics"
  }
}
 
# Create 2 Private Subnets
resource "aws_subnet" "private_subnet1" {
  
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}a"
 
  # 2,048 IP addresses each
  cidr_block = var.private_subnet1 
  tags = {
    Name        = "${var.project-name}-${var.infra_env}-private1-subnet"
    Project     = "${var.project-name}.com"
    Role        = "private"
    Environment = var.infra_env
    ManagedBy   = "dcgmechanics"
  }
}

resource "aws_subnet" "private_subnet2" {
  
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}b"
 
  # 2,048 IP addresses each
  cidr_block = var.private_subnet2
  tags = {
    Name        = "${var.project-name}-${var.infra_env}-private2-subnet"
    Project     = "${var.project-name}.com"
    Role        = "private"
    Environment = var.infra_env
    ManagedBy   = "dcgmechanics"
  }
}

#Allocate an Elastic IP for nat gateway
resource "aws_eip" "nat"{
    tags = {
    Name = "${var.project-name}-${var.infra_env}-eip-nat1"
    Project     = "${var.project-name}.com"
    Environment = var.infra_env
  }
}

# # create a nat gateway and attach it to all private subnet
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public_subnet1.id

  tags = {
    Name = "${var.project-name}-${var.infra_env}-nat-gw"
    Environment = var.infra_env
  }
}

/*
*** Create internet gateway
*/
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "${var.project-name}-${var.infra_env}-igw"
        Project     = "${var.project-name}.com"
        Environment = var.infra_env
    }
}

/*
*** Create route table for public subnet 
*/
resource "aws_route_table" "rt_public_subnet1" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "${var.project-name}-${var.infra_env}-public-rt1"
        Project     = "${var.project-name}.com"
        Environment = var.infra_env    
    }
}


/*
*** Attach route table to public subnet 
*/
resource "aws_route_table_association" "public_subnet1_rt_public_subnet1" {
    subnet_id = aws_subnet.public_subnet1.id
    route_table_id = aws_route_table.rt_public_subnet1.id
}

resource "aws_route_table_association" "public_subnet2_rt_public_subnet2" {
    subnet_id = aws_subnet.public_subnet2.id
    route_table_id = aws_route_table.rt_public_subnet1.id
}

/*
*** Create route table for private subnet1
*/
resource "aws_route_table" "rt_private_subnet1" {
    vpc_id = aws_vpc.vpc.id    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat-gw.id
    }
    tags = {
        Name = "${var.project-name}-${var.infra_env}-private-rt1"
        Project     = "${var.project-name}.com"
        Environment = var.infra_env    
    }
}

/*
*** Create route table for private subnet2
*/
resource "aws_route_table" "rt_private_subnet2" {
    vpc_id = aws_vpc.vpc.id    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat-gw.id
    }
    tags = {
        Name = "${var.project-name}-${var.infra_env}-private-rt2"
        Project     = "${var.project-name}.com"
        Environment = var.infra_env    
    }
}

/*
*** Attach route table to private subnet 
*/
resource "aws_route_table_association" "public_subnet1_rt_private_subnet1" {
    subnet_id = aws_subnet.private_subnet1.id
    route_table_id = aws_route_table.rt_private_subnet1.id
}

/*
*** Attach route table to private subnet 
*/
resource "aws_route_table_association" "public_subnet2_rt_private_subnet2" {
    subnet_id = aws_subnet.private_subnet2.id
    route_table_id = aws_route_table.rt_private_subnet2.id
}

