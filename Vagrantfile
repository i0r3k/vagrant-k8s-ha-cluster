$num_etcd = 3
$num_master = 3
$num_nodes = 3
$vm_cpus = 2
$vm_memory = 2048
$vm_box = "centos/7"
$vm_box_version = "1802.01"
#$vm_box = "Iorek/k8svirtualbox"
#$vm_box_version = "1.9.5"
$k8s_version = "v1.10.0"
$k8s_cluster_ip_tpl = "192.168.33.%s"
$k8s_master_ip = $k8s_cluster_ip_tpl % "21"
$vm_name_tpl = "vg-k8s-%s"
#$docker_registry="registry.cn-hangzhou.aliyuncs.com/ctag"
$docker_registry="iorek"
$virtual_ip="192.168.33.100"

Vagrant.configure("2") do |config|
	(1..$num_etcd).each do |i|	
		config.vm.define "etcd#{i}", primary: true do |etcd|
			etcd.vm.box = $vm_box
			etcd.vm.box_version = $vm_box_version

			etcd.vm.box_check_update = false
		  
			etcd.vm.hostname = "etcd#{i}"
		  
			etcd.vm.network "private_network", ip: $k8s_cluster_ip_tpl % "#{i+10}"

			etcd.vm.provider "virtualbox" do |vb|
				vb.name = $vm_name_tpl % "etcd-#{i}"
				vb.memory = $vm_memory
				vb.cpus = $vm_cpus
				vb.gui = false
			end
			
			etcd.vm.provision :shell, :path => 'preflight-etcd.sh', :name => 'preflight-etcd.sh'
			
			if i == 1
				etcd.vm.provision :shell, :path => 'generate-etcd-certs.sh', :name => 'generate-etcd-certs.sh'
			else
				etcd.vm.provision :shell, :path => 'setup-etcd-nodes.sh', :name => 'setup-etcd-nodes.sh'
			end
			
			etcd.vm.provision :shell, :path => 'run-etcd.sh', :name => 'run-etcd.sh'
		end
	end
	
	
	(1..$num_master).each do |i|
		config.vm.define "master#{i}", primary: true do |master|
			master.vm.box = $vm_box
			master.vm.box_version = $vm_box_version

			master.vm.box_check_update = false
		  
			master.vm.hostname = "master#{i}"
		  
			master.vm.network "private_network", ip: $k8s_cluster_ip_tpl % "#{i+20}"

			master.vm.provider "virtualbox" do |vb|
				vb.name = $vm_name_tpl % "master-#{i}"
				vb.memory = $vm_memory
				vb.cpus = $vm_cpus
				vb.gui = false
			end
			
			master.vm.provision :shell, :path => 'preflight.sh', :name => 'preflight.sh', :args => [$k8s_version, $docker_registry]			
			master.vm.provision :shell, :path => 'acquire-etcd-certs.sh', :name => 'acquire-etcd-certs.sh'
			#master.vm.provision :shell, :path => 'pull-docker-images.sh', :name => 'pull-docker-images.sh', :args => [$docker_registry]
			
			if i == 1
				master.vm.provision :shell, :path => 'keepalived.sh', :name => 'keepalived.sh', :args => [$virtual_ip, "MASTER", 100]
			else 
				master.vm.provision :shell, :path => 'keepalived.sh', :name => 'keepalived.sh', :args => [$virtual_ip, "BACKUP", 100-(i-1)*10]
				master.vm.provision :shell, :path => 'acquire-master-certs.sh', :name => 'acquire-master-certs.sh'
			end
			
			master.vm.provision :shell, :path => 'init-master.sh', :name => 'init-master.sh', :args => [$k8s_version, $docker_registry, $virtual_ip]
		end
	end
	
	(1..$num_nodes).each do |i|
		config.vm.define "node#{i}" do |node|
			node.vm.box = $vm_box
			node.vm.box_version = $vm_box_version

			node.vm.box_check_update = false
		  
			node.vm.hostname = "node#{i}"
		  
			node.vm.network "private_network", ip: $k8s_cluster_ip_tpl % "#{i+30}"

			node.vm.provider "virtualbox" do |vb|
				vb.name = $vm_name_tpl % "node-#{i}"
				vb.memory = $vm_memory
				vb.cpus = $vm_cpus
				vb.gui = false
			end
			
			node.vm.provision :shell, :path => 'preflight.sh', :name => 'preflight.sh', :args => [$k8s_version, $docker_registry]
			#node.vm.provision :shell, :path => 'pull-docker-images.sh', :name => 'pull-docker-images.sh', :args => [$docker_registry]
			
			node.vm.provision "shell", :name => 'inline-shell', inline: <<-SHELL
				echo "initialize node#{i}"
			SHELL
			
			node.vm.provision :shell, :path => 'join-cluster.sh', :name => 'join-cluster.sh'
			
			if i == $num_nodes
				node.vm.provision :shell, :path => 'configure-cluster.sh', :name => 'configure-cluster.sh', :args => [$virtual_ip]
			end
		end
	end
end
