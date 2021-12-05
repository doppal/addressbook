#! /usr/bin/env bash
pip3 install ansible==2.10.7
/home/user1/.local/bin/ansible --version
pip3 install boto3
/home/user1/.local/bin/ansible-inventory -i inventory_aws_ec2.yml
/home/user1/.local/bin/ansible-playbook docker-deploy.yml