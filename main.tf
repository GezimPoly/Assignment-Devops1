terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.30.0"
    }
  
  }
  required_version = "~> 1.6.6" // duhet me kqyre edhe nihere
}

provider "aws" {
  region = var.aws_region
  access_key = "AKIA452BZEEUW2ET4BM7"
  secret_key = "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"
}

//qetu me i majt te gjitha zone qe jane te mundshme mu qas e qat regjion
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  // We want the most recent AMI
  most_recent = "true"

  // We are filtering through the names of the AMIs. We want the 
  // Ubuntu 20.04 server
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  // We are filtering through the virtualization type to make sure
  // we only find AMIs with a virtualization type of hvm
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  // This is the ID of the publisher that created the AMI. 
  // The publisher of Ubuntu 20.04 LTS Focal is Canonical 
  // and their ID is 099720109477
  owners = ["099720109477"]
}

resource "aws_vpc" "devops1_vpc" {
  cidr_block          = var.vpc_cidr_block
 // enable_dns_hostname = true

  tags = { 
    Name = "devops1_vpc" 
    }
}
// me kriju internet gateway edhe me ja bashkangjit devops1_aws
resource "aws_internet_gateway" "devops1_igw"{
    vpc_id =aws_vpc.devops1_vpc.id

    tags={
        Name="devops1_igw"
    }
}
// creating subnets

resource "aws_subnet" "devops1_public_subnet" {
// me i numru resurset qe na dojne me ju kriju publuc subneta
  count =var.subnet_count.public

  vpc_id=aws_vpc.devops1_vpc.id


  cidr_block=var.public_subnet_cidr_blocks[count.index]
  //po i mbledhim zonat e availability prej t dhanav qe i kena nxirr
availability_zone = "us-east-1a"
//data.aws_availability_zones.available.names[count.index]

tags={
    Name="devops1_public_subnet_${count.index}"
}
}

resource "aws_subnet" "devops1_private_subnet" {
    count=var.subnet_count.private

    vpc_id = aws_vpc.devops1_vpc.id

    cidr_block=var.private_subnet_cidr_blocks[count.index]

    availability_zone=data.aws_availability_zones.available.names[count.index]
    
    tags={
        Name="devops1_private_subnet_${count.index}"
    }
}

resource "aws_route_table" "devops1_public_rt" {
    vpc_id=aws_vpc.devops1_vpc.id

    // pasi qe eshte route publike ka nevoj me u qase ne internet ,pe lojna me 0.0.0.0/0 edhe me ju qas internet
    //gateway "devops1_igw"
    route{
        cidr_block ="0.0.0.0/0"
        gateway_id =aws_internet_gateway.devops1_igw.id
    }
}
//ketu me i mbledh dhe vendos public subnets ne public route table
resource "aws_route_table_association" "public"{
    count =var.subnet_count.public
    route_table_id =aws_route_table.devops1_public_rt.id



    subnet_id = aws_subnet.devops1_public_subnet[count.index].id
}

// per private
resource "aws_route_table" "devops1_private_rt" {
    vpc_id=aws_vpc.devops1_vpc.id

}
resource "aws_route_table_association" "private" {
    count =var.subnet_count.private
    route_table_id =aws_route_table.devops1_private_rt.id

    subnet_id =aws_subnet.devops1_private_subnet[count.index].id
  
}

// me kriju security per ec2
resource "aws_security_group" "devops1_web_sg" {
  name        = "devops1_web_sg"
  description = "Security group for devops1 web servers"
  vpc_id      = aws_vpc.devops1_vpc.id

  // si fillim per me pas ne http duhet m ei kriju trafikun prej protit 80 tcp
  ingress {
    description = "Allow all traffic through HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //per me mujt me u qas vetem une nepermjet SSH duhet me kriju trafik veq per ip e mia
  ingress {
    description = "Allow SSH from my computer"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
   // cidr_blocks = ["${var.my_ip}/32"]
    //ktu e kom hiq ip e mia se nuk me i mar 
  }



  // kjo i lejon krejt outbound trafic me kalu ne ec2
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Here we are tagging the SG with the name "devops1_web_sg"
  tags = {
    Name = "devops1_web_sg"
  }
}
  



// me kriju security goupe per RDS 
resource "aws_security_group" "devops1_db_sg" {
  name        = "devops1_db_sg"
  description = "Security group for devops1 databases"
  vpc_id      = aws_vpc.devops1_vpc.id

 
  ingress {
    description     = "Allow MySQL traffic from only the web sg"
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "tcp"
    security_groups = [aws_security_group.devops1_web_sg.id]
  }

  // Here we are tagging the SG with the name "devops1_db_sg"
  tags = {
    Name = "devops1_db_sg"
  }
}

resource "aws_db_subnet_group" "devops1_db_subnet_group" {
  // The name and description of the db subnet group
  name        = "devops1_db_subnet_group"
  description = "DB subnet group for devops1"
  

  subnet_ids  = [for subnet in aws_subnet.devops1_private_subnet : subnet.id]
}

//me kriju nje DB instance
resource "aws_db_instance" "devops1_database" {

  // ktu o madhesin e storage ne gigabit 10 qe e kena vendos ne fillim
  allocated_storage      = var.settings.database.allocated_storage
  
#   engine qe e kena vendos per database
  engine                 = var.settings.database.engine
  
  // versioni i databasess
  engine_version         = var.settings.database.engine_version
  
  // settings.database.instance_class eshte "db.t2.micro"
  instance_class         = var.settings.database.instance_class
  

  // emri i databases
  db_name                = var.settings.database.db_name
  // username te secrets  
  username               = var.db_username
  
 
  password               = var.db_password
  
  db_subnet_group_name   = aws_db_subnet_group.devops1_db_subnet_group.id
  //security groupe per db
  vpc_security_group_ids = [aws_security_group.devops1_db_sg.id]
  
  
  //kjo eshte boolean 
// skip_final_snapshot    = var.settings.database.skip_final_snapshot
 }

// Create a key pair named "devops1_kp"
resource "aws_key_pair" "devops1_kp" {
  // Give the key pair a name
  key_name   = "devops1_kp"
  
  public_key = file("devops1_kp.pub")
}

// Create an EC2 instance named "devops1_web"
resource "aws_instance" "devops1_web" {
  //numeri i instancav qe i dojna me i pas ket rast o 1
  count                  = var.settings.web_app.count
  
  // Here we need to select the ami for the EC2. We are going to use the
  // ami data object we created called ubuntu, which is grabbing the latest
  // Ubuntu 20.04 ami
  //?? duhet me kqyre qeta edhe nihere
  ami                    = data.aws_ami.ubuntu.id
  
  // This is the instance type of the EC2 instance. The variable
  // settings.web_app.instance_type is set to "t2.micro"
  instance_type          = var.settings.web_app.instance_type
  
  // The subnet ID for the EC2 instance. Since "devops1_public_subnet" is a list
  // of public subnets, we want to grab the element based on the count variable.
  // Since count is 1, we will be grabbing the first subnet in  	
  // "devops1_public_subnet" and putting the EC2 instance in there
  subnet_id              = aws_subnet.devops1_public_subnet[count.index].id
  
  // The key pair to connect to the EC2 instance. We are using the "devops1_kp" key 
  // pair that we created
  key_name               = aws_key_pair.devops1_kp.key_name
  
  // The security groups of the EC2 instance. This takes a list, however we only
  // have 1 security group for the EC2 instances.
  vpc_security_group_ids = [aws_security_group.devops1_web_sg.id]

  // We are tagging the EC2 instance with the name "devops1_db_" followed by
  // the count index
  tags = {
    Name = "devops1_web_${count.index}"
  }
}

// Create an Elastic IP named "devops1_web_eip" for each
// EC2 instance
resource "aws_eip" "devops1_web_eip" {
	// count is the number of Elastic IPs to create. It is
	// being set to the variable settings.web_app.count which
	// refers to the number of EC2 instances. We want an
	// Elastic IP for every EC2 instance
  count    = var.settings.web_app.count

	// The EC2 instance. Since devops1_web is a list of 
	// EC2 instances, we need to grab the instance by the 
	// count index. Since the count is set to 1, it is
	// going to grab the first and only EC2 instance
  instance = aws_instance.devops1_web[count.index].id

	// We want the Elastic IP to be in the VPC
  vpc = true

	// Here we are tagging the Elastic IP with the name
	// "devops1_web_eip_" followed by the count index
  tags = {
    Name = "devops1_web_eip_${count.index}"
  }
  
}
