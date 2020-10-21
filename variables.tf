##############################################################################
# Account Variables
##############################################################################

variable unique_id {
  description = "unique identifiers for all created resources"
  type        = string
}

variable ibmcloud_api_key {
  description = "api key for IBM Cloud"
  type        = string
}

variable generation {
  description = "Generation for VPC"
  type        = number
  default     = 2
}

variable ibm_region {
  description = "region where all created resources will be deployed"
  type        = string
}

variable cluster {
  description = "name of existing kubernetes cluster"
  type        = string
}

variable resource_group {
  description = "resource group of existing kubernetes cluster"
  type        = string
  default     = "sharedrg"
}

##############################################################################

##############################################################################
# Block Storage Variables
##############################################################################

variable capacity {
  description = "Capacity for all block storage volumes provisioned in gigabytes"
  type        = number
  default     = 100
}

variable profile {
  description = "The profile to use for this volume."
  type        = string
  default     = "10iops-tier"
}

##############################################################################

##############################################################################
# Deployment variables
##############################################################################

variable image_name {
  description = "image for deployment where portworx volume will be mounted to for use"
  type        = string
  default     = "test"
}

variable file_path {
  description = "path for the portworx volume to be mounted to on the pods of the deployment"
  type        = string
  default     = "/portworxDir"
}

##############################################################################
