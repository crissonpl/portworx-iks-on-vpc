##############################################################################
# Portworx, a Cloud-native persistent storage and data management 
# solution for Kubernetes and OpenShift clusters.
##############################################################################

resource ibm_resource_instance portworx {
  name              = "${var.unique_id}-portworx"
  service           = "portworx"
  plan              = "px-enterprise"
  location          = var.ibm_region
  resource_group_id = data.ibm_resource_group.group.id

  tags = [
    "clusterid:${data.ibm_container_vpc_cluster.cluster.id}"
  ]

  parameters = {
    apikey        = var.ibmcloud_api_key
    cluster_name  = var.cluster
    clusters      = var.cluster
    internal_kvdb = "internal"
    secret_type   = "k8s"
  }

  /*
  * We can't create a pvc until the portworx service is up and running. This 
  * resource will handle that check
  */
  provisioner "local-exec" {
    environment = {
      CONFIGPATH = data.ibm_container_cluster_config.cluster.config_file_path
    }

    interpreter = ["/bin/bash", "-c"]
    command     = file("${path.root}/scripts/portworx.sh")
  }

  /* 
  * Currently, deleting the portworx service instance does not uninstall portworx
  * from the cluster. This resource will handle uninstalling portworx from the 
  * cluster.  
  */
  provisioner "local-exec" {
    when = destroy
    environment = {
      CONFIGPATH   = data.ibm_container_cluster_config.cluster.config_file_path
      KUBE_VERSION = data.ibm_container_vpc_cluster.cluster.kube_version
    }

    interpreter = ["/bin/bash", "-c"]
    command     = file("${path.root}/scripts/portworx_destroy.sh")
  }

  depends_on = [
    null_resource.volume_attachment,
    kubernetes_cluster_role_binding.default
  ]
}

##############################################################################