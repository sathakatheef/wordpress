locals {
  wordpress_nonprod_db = [
    {
      db_name          = "wordpress_dev"
      username         = "admin"
      password         = "test1234"
      min_capacity     = 2
      max_capacity     = 2
      db_backup_window = "13:00-14:30"
    },
  ]
}

module "wordpress_dev" {
  source = "https://github.com/sathakatheef/wordpress/tree/master/aws/modules"
  }
