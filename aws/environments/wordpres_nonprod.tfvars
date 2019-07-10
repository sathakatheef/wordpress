# Account Name
   account_name		   = "test"
# Environment
    environment            = "dev"
# Product_roles
    product_roles          = ["app","web","db"]
#Product
    product		   = "wordpress"
# Network
    cidr_block             = "10.25.0.0/16"
# amazon Key Pair
     key_pair_name         = {"amazon-prod" = "amazon-prod"}
# Path for IAM-role
     role_path             = "/service-role/"
# role_type for IAM_Role
     role_type             = "Service"
# *.1-stop.biz certificate
     cert_body             = "../../../../certs/cert-body.pem"
     cert_privatekey       = "../../../../certs/cert-key.pem"
     cert_chain            = "../../../../certs/cert-chain.pem"
