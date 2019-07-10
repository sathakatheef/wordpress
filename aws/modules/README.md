###### Module Section containig AWs Resources
* Resources can be reused form this section for different environments.
   * Resource/modules created: 
  
    * vpc: vpc, dhcp_option, subnets (private and public), NACLs, IGW, NGW, VGW, Route table Associations, EIP, EIP association (NGW), NGW association (public subnets), default security group
      
    * acm: wildcard certificate
  
    * asg: launch_config, auto_scaling, auto_scaling policies, cloud watch metric (CPU utilization), auto_scaling notification
  
    * sns: sns topics for auto scaling to notify the scaling events depending on which ASG will scale up or down.
  
    * alb: alb, http listener, hhtps listener, https forward listener rule
  
    * target_group: target groups of instance type for the ALB  
  
    * iam_role: iam roles for the EC2 instances from the ASG
  
    * key_pair: EC2 key_pair
 
    * rds: creates aurora-mysql cluster
 
    * security_group: creates a standard security group that allows only private IPs   
  
  
* __variables.tf__ file will have all the variables defined that are required for the resources.
* __outputs.tf__ file will have all the outputs defined depending on the environment requirements.
