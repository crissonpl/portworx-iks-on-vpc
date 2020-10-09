##############################################################################
# Attach one block storage volume to each worker
##############################################################################

data ibm_container_vpc_cluster_worker worker {
  count             = length(data.ibm_container_vpc_cluster.cluster.workers)
  worker_id         = element(data.ibm_container_vpc_cluster.cluster.workers, count.index)
  cluster_name_id   = data.ibm_container_vpc_cluster.cluster.id
  resource_group_id = data.ibm_resource_group.group.id
}

##############################################################################


##############################################################################
# Subnets for Cluster Workers
##############################################################################

data ibm_is_subnet subnet {
  count      = length(data.ibm_container_vpc_cluster_worker.worker)
  identifier = data.ibm_container_vpc_cluster_worker.worker[count.index].network_interfaces[0].subnet_id
}

##############################################################################


##############################################################################
# Block Storage Volumes
##############################################################################

resource ibm_is_volume volume {
  count          = length(data.ibm_container_vpc_cluster.cluster.workers)
  name           = "vol-worker-${element(split("-", data.ibm_container_vpc_cluster.cluster.workers[count.index]), 4)}"
  capacity       = var.capacity
  profile        = var.profile
  zone           = data.ibm_is_subnet.subnet[count.index].zone
  resource_group = data.ibm_resource_group.group.id
}

##############################################################################


##############################################################################
# Attach Volumes
##############################################################################

resource null_resource volume_attachment {
  count = length(data.ibm_container_vpc_cluster_worker.worker)

  provisioner "local-exec" {
    environment = {
      TOKEN             = data.ibm_iam_auth_token.token.iam_access_token
      REGION            = var.ibm_region
      RESOURCE_GROUP_ID = data.ibm_resource_group.group.id
      CLUSTER_ID        = data.ibm_container_vpc_cluster.cluster.id
      WORKER_ID         = data.ibm_container_vpc_cluster_worker.worker[count.index].id
      VOLUME_ID         = ibm_is_volume.volume[count.index].id
    }

    interpreter = ["/bin/bash", "-c"]
    command     = file("${path.root}/scripts/volume_attachment.sh")
  }

  provisioner "local-exec" {
    when = destroy
    environment = {
      TOKEN             = data.ibm_iam_auth_token.token.iam_access_token
      REGION            = var.ibm_region
      RESOURCE_GROUP_ID = data.ibm_resource_group.group.id
      CLUSTER_ID        = data.ibm_container_vpc_cluster.cluster.id
      WORKER_ID         = data.ibm_container_vpc_cluster_worker.worker[count.index].id
      VOLUME_ID         = ibm_is_volume.volume[count.index].id
    }

    interpreter = ["/bin/bash", "-c"]
    command     = file("${path.root}/scripts/volume_attachment_destroy.sh")
  }
}

##############################################################################