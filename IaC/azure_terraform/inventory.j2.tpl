[control_plane]
%{ for ip in control_ips }
${ip.address}
%{ endfor }

[worker_nodes]
%{ for ip in worker_ips }
${ip.address}
%{ endfor }