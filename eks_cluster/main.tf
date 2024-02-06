terraform {
  backend "s3" {
    bucket         = "dev-terraform-remote-state-123"
    region         = "us-east-1"
    key            = "eks-cluster-terraform-state"
  }
}

data "terraform_remote_state" "cluster_vpc" {
  backend = "s3"

  config = {
    bucket = "dev-terraform-remote-state-123"
    key    = "vpc_state"
    region = "us-east-1"
  }
}



resource "aws_eks_cluster" "cluster" {
  name     = "dev-cluster"
  role_arn = data.terraform_remote_state.cluster_vpc.outputs.iam_controlplane

  vpc_config {
    subnet_ids = [data.terraform_remote_state.cluster_vpc.outputs.subnet_1, data.terraform_remote_state.cluster_vpc.outputs.subnet_2, data.terraform_remote_state.cluster_vpc.outputs.subnet_3]
    # vpc_id has error when specifying it Error: "Can't configure a value for "vpc_config.0.vpc_id": its value will be decided automatically based on the result of applying this configuration."
    #vpc_id = data.terraform_remote_state.cluster_vpc.outputs.vpc_id
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  #depends_on = [
  # aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  #]
}

resource "aws_eks_addon" "example" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "vpc-cni"
}

data "aws_key_pair" "eks-keypair" {
  key_name           = "EKS_WORKER"
  include_public_key = true
}

resource "aws_eks_node_group" "dev-node-group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "dev-node-group"
  node_role_arn   = data.terraform_remote_state.cluster_vpc.outputs.iam_worker
  subnet_ids      = [data.terraform_remote_state.cluster_vpc.outputs.subnet_1, data.terraform_remote_state.cluster_vpc.outputs.subnet_2, data.terraform_remote_state.cluster_vpc.outputs.subnet_3]
  remote_access {
    ec2_ssh_key = data.aws_key_pair.eks-keypair.key_name
  }

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
 # depends_on = [
  #  aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
   # aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
   # aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  #]
}

