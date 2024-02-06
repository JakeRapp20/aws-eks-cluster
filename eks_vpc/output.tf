output "vpc_id" {
  value = aws_vpc.eks-dev-vpc.id
}

output "subnet_1" {
  value =  aws_subnet.subnet-1.id
}

output "subnet_2" {
  value =  aws_subnet.subnet-2.id
}

output "subnet_3" {
  value =  aws_subnet.subnet-3.id
}

output "iam_worker" {
    value = aws_iam_role.worker_role.arn
}

output "iam_controlplane" {
    value = aws_iam_role.controlplane_role.arn
}
