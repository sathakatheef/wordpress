##### Dev Environment
* The terraform commands are executed in this directory to build the dev environment.
* The dev variables are passed in the .tfvars files and passed to the resources in the module section.
* The __wordpress_dev__.tf file calls the modules in the modules section through a module block.
* The variable files are symlinked to this directory so as to reuse it in building other environments by just editing the file in one place as per the requirements.
     * __aws-accounts.tf__: holds the names of the  AWS accounts in a named format. These names should be the same as those configured (using user credentials) in the AWS directory.
     * __aws-global.tf__: Will hold some default variables like provider details.
     * __wordpress_nonprod.tfvars__: will hold the environment variables. All the variables for the resources in the module section are retrieved from here.
* __backends.tf__ file holds the state of the environment/resources created. The state file is maintained in a S3 bucket and evrytime when there is a change to the environment, the state is maintained on the same file in the s3 bucket or the current state is retrieved from the same state file.    
