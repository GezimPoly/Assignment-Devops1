//per me perzgjedh regjionin
variable "aws_region"{
    default = "us-east-1"
 //default = "us-east-1b"
}
// me kriju range te vpc
variable "vpc_cidr_block"{
    description = "CIDR block for VPC"
    type = string
    default = "10.0.0.0/16"
}

// numri i subnetav publik dhe private
variable "subnet_count" {
    description = "Number of subnets"
    type = map(number)
    default = {
      public = 1,
      private= 1
    } 
}

// te dhenat per rds dhe ec2
variable "settings" {
    description = "Configuration settings"
    type = map(any)
    default = {
      "database"={
        allocated_storage=10   //storage in gigabytes
        engine ="mysql"
        engine_version ="8.0.27" // me kqyr edhe qafer versione ka te tjera 
        instance_class ="db.t2.micro"  //lloji i rds
        db_name = "devops1"
       skip_final_snapshpt =true   //me pyt muharremi a duhet me lon qeta

      },
      "web_app"={
        count =1  // sa ec2 instance me i lon
        instance_type ="t2.micro" // lloji i ec2
      }
    }
}
//subnetat per public tash pi shkoj nbazz te diagramit ?? a duhet me i shtu ma shume a jon boll qeto??
variable "public_subnet_cidr_blocks"{
    description = "Avaible CIDR blocks for public subnets"
    type = list(string)
    default = [ "10.0.1.0/24" ]
}

variable "private_subnet_cidr_blocks"{
    description = "Avaible CIDR blocks for private subnets"
    type = list(string)
    default = [ "10.0.2.0/24" ]
}


//Ip addres e jemja per me vendos ssh 
# variable "my_ip" {
#     description = "Your IP address"
#     type = string
#     sensitive = true
# }
variable "aws_access_key" {
  type = string
  sensitive = true
}
variable "aws_secret_key" {
  type = string
  sensitive = true
}

// database master user me rujt ne nje secrete file
variable "db_username" {
    description = "Database master user"
    type = string
    sensitive = true
}

// ktu per password te username
variable "db_password" {
  description = "Database master user password"
  type = string
  sensitive = true
}
