#cloud-config
bootcmd:
  - echo 'PermitRootLogin no' | sudo tee -a /etc/ssh/sshd_config
runcmd:
  - systemctl restart sshd
users:
  - name: ${ansible_user}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: wheel
    ssh_import_id: None
    lock_passwd: true
    ssh_authorized_keys:
      - ${ansible_public_key}