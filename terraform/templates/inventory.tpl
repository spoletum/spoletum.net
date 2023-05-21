all:
  vars:
    ansible_user: ${ ansible_user }

bastion:
  hosts:
    albornoz.spoletum.net:
      ansible_host: ${ bastion_ip_addr }
  vars:
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'

consul:
  hosts:
%{ for server in controlplane ~}
    ${ server.name }: 
      ansible_host: ${ server.ip4_address[0] }
%{ endfor ~}
  vars:
    ansible_ssh_common_args: '-o ProxyJump=${ ansible_user }@${ bastion_ip_addr } -o StrictHostKeyChecking=no'