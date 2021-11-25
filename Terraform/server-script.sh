           #!/bin/bash
  sudo yum install -y httpd && sudo yum install -y docker
  sudo systemctl start docker,httpd
  sudo systemctl enable docker,httpd
  sudo usermod -aG docker ec2-usermod