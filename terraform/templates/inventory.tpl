[all:vars]
ansible_user=${ ansible_user }
ansible_ssh_common_args='-o ProxyJump=${ ansible_user }@${ bastion_ip_addr } -o StrictHostKeyChecking=no'

[bastion]
albornoz.spoletum.net ansible_host=${ bastion_ip_addr }

[bastion:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[consul]
%{ for server in controlplane ~}
${ server.name } ansible_host=${ server.ip4_address[0] }
%{ endfor ~}