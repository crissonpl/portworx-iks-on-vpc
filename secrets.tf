##############################################################################
# Copy the image pull secrets from the default to the kube-system namespace 
# so that you can pull images from Container Registry. 
# https://cloud.ibm.com/docs/containers?topic=containers-registry#copy_imagePullSecret
##############################################################################

locals {
  namespace = "kube-system"
}

data kubernetes_secret image_pull_secret {
  metadata {
    name      = "all-icr-io"
    namespace = "default"
  }
}

resource kubernetes_secret copy_image_pull_secret {
  metadata {
    name      = "${local.namespace}-icr-io"
    namespace = local.namespace
  }

  data = {
    ".dockerconfigjson" = "${data.kubernetes_secret.image_pull_secret.data[".dockerconfigjson"]}"
  }

  type = "kubernetes.io/dockerconfigjson"
}

##############################################################################


##############################################################################
# Add the image pull secrets to the Kubernetes service account of the 
# kube-system namespace.
# https://cloud.ibm.com/docs/containers?topic=containers-registry#store_imagePullSecret
##############################################################################

resource null_resource update_image_pull_secrets {
  provisioner "local-exec" {
    environment = {
      NAMESPACE   = local.namespace
      CONFIGPATH  = data.ibm_container_cluster_config.cluster.config_file_path
      SECRET_NAME = kubernetes_secret.copy_image_pull_secret.metadata.0.name
    }

    interpreter = ["/bin/bash", "-c"]
    command     = file("${path.root}/scripts/update_image_pull_secrets.sh")
  }

  provisioner "local-exec" {
    when = destroy
    environment = {
      NAMESPACE   = local.namespace
      CONFIGPATH  = data.ibm_container_cluster_config.cluster.config_file_path
      SECRET_NAME = kubernetes_secret.copy_image_pull_secret.metadata.0.name
    }

    interpreter = ["/bin/bash", "-c"]
    command     = file("${path.root}/scripts/update_image_pull_secrets_destroy.sh")
  }
}

##############################################################################