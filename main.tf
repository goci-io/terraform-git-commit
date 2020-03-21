locals {
  file_source_keys   = keys(var.paths)
  content_hash       = var.changes ? md5(join("\n", local_file.rendered.*.content)) : 1
  templates_root_dir = var.templates_root_dir == "" ? path.module : var.templates_root_dir
  repository_remote  = format("%s@%s:%s/%s.git", var.git_user, var.git_base_url, var.git_organization, var.git_repository)
  repository_dir     = format("/conf/git/checkout/%s/repository", random_string.temp_repo_dir.result)
}

resource "random_string" "temp_repo_dir" {
  length  = 21
  special = false
}

resource "local_file" "rendered" {
  count      = var.enabled ? length(local.file_source_keys) : 0
  filename   = abspath(format("%s/../changes/%s", local.repository_dir, lookup(var.paths[local.file_source_keys[count.index]], "target")))
  content    = templatefile(format("%s/%s", local.templates_root_dir, element(local.file_source_keys, count.index)), lookup(var.paths[local.file_source_keys[count.index]], "data"))
}

resource "null_resource" "commit" {
  count      = var.enabled ? 1 : 0
  depends_on = [var.commit_depends_on, local_file.rendered]

  provisioner "local-exec" {
    command = "${path.module}/scripts/commit.sh ${join(" ", [
      var.git_base_url,
      var.git_user,
      var.ssh_key_file,
      local.repository_remote,
      local.repository_dir,
      var.branch,
      "'${var.message}'"
    ])}"
  }

  triggers = {
    hash = local.content_hash
  }
}
