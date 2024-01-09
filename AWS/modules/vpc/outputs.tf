output "vpc_id" {
  value = aws_vpc.vpc.id
}
 
output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}
 
output "vpc_public_subnet1" {
  # Result is a map of subnet id to cidr block, e.g.
  # for subnet in aws_subnet.public :
    value = aws_subnet.public_subnet1.id

}

output "vpc_public_subnet2" {
  # Result is a map of subnet id to cidr block, e.g.
  # for subnet in aws_subnet.public :
    value = aws_subnet.public_subnet2.id

}

output "vpc_private_subnet1" {
  # Result is a map of subnet id to cidr block, e.g.
  # for subnet in aws_subnet.public :
    value = aws_subnet.private_subnet1.id

}

output "vpc_private_subnet2" {
  # Result is a map of subnet id to cidr block, e.g.
  # for subnet in aws_subnet.public :
    value = aws_subnet.private_subnet2.id

}