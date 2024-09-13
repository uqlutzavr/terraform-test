variable "my_vpc_cidr" {
    description = "CIDR for my_vpc"
    type = string
    default = "10.0.0.0/16"
}

variable "general_tag" {
    description = "General tag"
    type = map(any)
    default = {
        Environment = "dev"
        Owner = "Pavlo"
        }
}

variable "subnet_cidr_public" {
    description = "Public CIDR for subnet"
    type = list(string)
    default = [ "10.0.1.0/24", "10.0.2.0/24" ]
}

variable "subnet_cidr_private" {
    description = "Private CIDR for subnet"
    type = list(string)
    default = [ "10.0.10.0/24", "10.0.20.0/24" ]
}