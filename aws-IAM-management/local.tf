locals {
    users_data = yamldecode(file("${path.module}/users.yaml")).users
    
}