module "web_mail" {
    source = "git@github.com:adityalakku/terraform-ans-proj.git"
    my_region = var.my_aws_region
    domain_name = var.my_domain_name
    web_sub_domain_name = var.my_web_sub_domain_name
    mail_sub_domain_name = var.my_mail_sub_domain_name
    key_name = var.my_key_name
    local_aws_private_key_path = var.my_local_aws_private_key_path
    web_want = var.my_web_want
    web_count = var.my_web_count
    mail_want = var.my_mail_want
    mail_count = var.my_mail_count  
}


resource "null_resource" "ansible_playbook" {
  triggers = {
    file_changed = md5(local_file.loops.content)
    hosts_changed = md5(local_file.hosts.content)
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i hosts loops.yml"
  }

  depends_on = [
    local_file.loops
  ]
}
resource "local_file" "loops" {
  content = templatefile("${path.module}/users.tmpl", {
    names = var.names
    status = var.status
  })
  filename = "${path.module}/loops.yml"
}
resource "local_file" "hosts" {
  content = templatefile("${path.module}/hosts.tmpl", {
    web_server_host = module.web_mail_db.web_server_public_ip[0]
    mail_server_host = module.web_mail_db.mail_server_public_ip[0]
  })
  filename = "${path.module}/hosts"
}
