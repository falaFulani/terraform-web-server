#Simple AWS Terraform Code

- These code aims at creating the following infrastucture resource on AWS for a ubuntu webserver

1. VPC
2. A subnet
3. Network Interface
4. Route table
5. Subnet Route table association
6. Internet gateway
7. Elastic IP address
8. Security group allowing trafic from port 22, 80 and 443
9. Ubuntu instance with apache2 installed.


#To Run 

Run the following commands 

1. terraform plan (list all items to be created)
2. terraform apply (to apply the plan)

#Note

Run terraform destory command if you are just practising Infrastuctre as Code, otherwise you might incure some charges.
