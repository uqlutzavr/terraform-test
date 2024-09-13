module "prod" {
    source = "./modules/network"
    my_vpc_cidr = "192.168.0.0/16"
    general_tag = {
        Environment = "prod"
        Owner = "Pavlo"
        }
    subnet_cidr_public = ["192.168.1.0/24"]
    subnet_cidr_private = ["192.168.10.0/24"]
}

module "dev" {
    source = "./modules/network"
    my_vpc_cidr = "10.0.0.0/16"
    general_tag = {
        Environment = "dev"
        Owner = "Pavlo"
        }
    subnet_cidr_public = ["10.0.1.0/24"]
    subnet_cidr_private = ["10.0.10.0/24"]
}
