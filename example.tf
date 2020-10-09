##############################################################################
# Example usage of portworx
##############################################################################

resource kubernetes_persistent_volume_claim example {
  metadata {
    name = "${var.unique_id}-example-pvc"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "portworx-shared-sc"
  }

  depends_on = [ibm_resource_instance.portworx]
}

resource null_resource deployment {
  triggers = {
    deployment_label = var.unique_id
    image_name       = var.image_name
    file_path        = var.file_path
  }

  provisioner "local-exec" {
    environment = {
      DEPLOYMENT_LABEL = self.triggers.deployment_label
      IMAGE_NAME       = self.triggers.image_name
      FILE_PATH        = self.triggers.file_path
      CONFIGPATH       = data.ibm_container_cluster_config.cluster.config_file_path
      PVC_NAME         = kubernetes_persistent_volume_claim.example.metadata.0.name
    }

    interpreter = ["/bin/bash", "-c"]
    command     = file("${path.root}/scripts/deployment.sh")
  }

  provisioner "local-exec" {
    when = destroy
    environment = {
      DEPLOYMENT_LABEL = self.triggers.deployment_label
      CONFIGPATH       = data.ibm_container_cluster_config.cluster.config_file_path
    }

    interpreter = ["/bin/bash", "-c"]
    command     = file("${path.root}/scripts/deployment_destroy.sh")
  }
}

##############################################################################