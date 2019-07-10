# wordpress
Sample AWS Infrastructure using Terraform Infrastructure as Code service to construct a Wordpress Site in dev and production.

### Full Tree Structure
~~~
├ README.md
├ aws
│   ├ environments
│   │   ├ wordpress_nonprod.tfvars
│   │   └ wordpress_prod.tfvars
│   ├ modules
│   │   ├ acm.tf
│   │   ├ asg.tf
│   │   ├ iam_roles.tf
│   │   ├ key_pair.tf
│   │   ├ load_balancer.tf
│   │   ├ outputs.tf
│   │   ├ rds.tf
│   │   ├ securitygroup.tf
│   │   ├ sns.tf
│   │   ├ target_group.tf
│   │   ├ variables.tf
│   │   └ vpc.tf
│   ├ projects
│   │   └ wordpress
│   │       ├ dev
│   │       │   ├ aws-accounts.auto.tf -> ../../../variables/aws-accounts.tf
│   │       │   ├ aws-global.auto.tf -> ../../../variables/aws-global.tf
│   │       │   ├ user_data.sh
│   │       │   ├ wordpress_dev.tf
│   │       │   └ wordpress_nonprod.auto.tfvars -> ../../../environments/wordpress_nonprod.tfvars
│   │       └ production
│   │           ├ aws-accounts.auto.tf -> ../../../variables/aws-accounts.tf
│   │           ├ aws-global.auto.tf -> ../../../variables/aws-global.tf
│   │           ├ backends.tf
│   │           ├ user_data.sh
│   │           ├ wordpress_prod.auto.tfvars -> ../../../environments/wordpress_prod.tfvars
│   │           └ wordpress_prod.tf
│   └ variables
│       ├ aws-accounts.tf
│       └ aws-global.tf
└ certs
    ├ cert-body.pem
    ├ cert-chain.pem
    └ cert-key.pem
~~~

### Structure Definition
The structure is didvide in __two__ main structures, __modules__ and __projects__
* modules sections will have all the resources part that are required.
* projects section will have the variables that will be passed to the resources in the module section.
* The main purpose of this approach is to enhance the reusability of the modules.
