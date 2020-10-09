##############################################################################
# IBM Cloud Provider
##############################################################################
provider ibm {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.ibm_region
  generation       = var.generation
}

##############################################################################


##############################################################################
# Authorization Token For API Calls
##############################################################################

data ibm_iam_auth_token token {}

##############################################################################


##############################################################################
# Resource Group Where Cluster is Provisioned
##############################################################################

data ibm_resource_group group {
  name = var.resource_group
}

##############################################################################

##############################################################################
# Cluster Data
##############################################################################

data ibm_container_vpc_cluster cluster {
  name              = var.cluster
  resource_group_id = data.ibm_resource_group.group.id
}

data ibm_container_cluster_config cluster {
  cluster_name_id   = var.cluster
  resource_group_id = data.ibm_resource_group.group.id
  admin             = true
  config_dir        = path.root
}

##############################################################################

##############################################################################
# Kubernetes Provider
##############################################################################

provider kubernetes {
  load_config_file       = false
  host                   = data.ibm_container_cluster_config.cluster.host
  client_certificate     = data.ibm_container_cluster_config.cluster.admin_certificate
  client_key             = data.ibm_container_cluster_config.cluster.admin_key
  cluster_ca_certificate = data.ibm_container_cluster_config.cluster.ca_certificate
}

##############################################################################
