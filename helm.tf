##############################################################################
# Give tiller service account admin permissions
##############################################################################

resource kubernetes_cluster_role_binding default {
  metadata {
    name = "default-cluster-rule"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }

  depends_on = [null_resource.update_image_pull_secrets]
}

##############################################################################