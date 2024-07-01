This project creates basic infrastructure on AWS for a website using Terraform.
The website runs on two EC2 instances in different availability zones behind an application load balancer.
The terraform configuration file generates load balancer's DNS name as output. This DNS name can then be used to open the webpage of the website over HTTP.
