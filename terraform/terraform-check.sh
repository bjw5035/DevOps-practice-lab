#!/bin/sh

echo "================== Terraform fmt ... =================="
terraform fmt
echo "================== Terraform fmt exit =================="

echo "================== Terraform validate ... =================="
terraform validate
echo "================== Terraform validate exit =================="

echo "================== Terraform plan ... =================="
terraform plan
echo "================== Terraform plan exit =================="
