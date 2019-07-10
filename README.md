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
│   │   ├ README.md
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
│   │       │   ├ README.md
│   │       │   ├ aws-accounts.auto.tf -> ../../../variables/aws-accounts.tf
│   │       │   ├ aws-global.auto.tf -> ../../../variables/aws-global.tf
│   │       │   ├ backends.tf
│   │       │   ├ user_data.sh
│   │       │   ├ wordpress_dev.tf
│   │       │   └ wordpress_nonprod.auto.tfvars -> ../../../environments/wordpress_nonprod.tfvars
│   │       └ production
│   │           ├ README.md
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
    ├ README.md
    ├ cert-body.pem
    ├ cert-chain.pem
    └ cert-key.pem

~~~

### Structure Definition
The structure is divided in __two__ main structures, __modules__ and __projects__
* modules sections will have all the resources part that are required.
* projects section will have the variables that will be passed to the resources in the module section.
* The main purpose of this approach is to enhance the reusability of the modules.

### Main Terraform Commands in brief
* Resources through Terraform is built using three main commands __terraform init__, terraform plan__ and terraform apply__.
* terraform init command: initializes all the tf files in the directory. [terraform_init](https://www.terraform.io/docs/commands/init.html)
* terraform plan command: will give a plan of what resources are going to created, modified or destroyed. (terraform plan also shows error during the plan). [terraform_plan](https://www.terraform.io/docs/command
s/plan.html)
* terraform apply command: will create, modify or destroy the resources shown by the plan. Apply requires user intervention (yes or no) to approve the plan and apply. [terraform_apply](https://www.terraform.io/docs/commands/apply.html)
* The __terraform destroy__ command will destroy the resource. Destroy requires user intervention (yes or no) to approve the plan and destroy. [terraform_destroy](https://www.terraform.io/docs/commands/destroy.html)
* The __terraform output__ command will show the output of the resources, if any output is configured for that resource. [terraform_output](https://www.terraform.io/docs/commands/output.html)
* The __terraform refresh__ command will reconcile the state Terraform knows about (via its state file) with the real-world infrastructure. This can be used to detect any drift from the last-known state, and to update the state file. [terraform_refresh](https://www.terraform.io/docs/commands/refresh.html)

### Process Flow
* The terraform commands should be executed in the modules section:
    * for dev: /aws/projects/wordpress/dev/
    * for production: /aws/projects/wordpress/production/
* This approach is so as to resuse the modules for different environments.
