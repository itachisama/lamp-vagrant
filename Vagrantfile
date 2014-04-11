Vagrant.configure("2") do |config|
	# Nome da box.  
	config.vm.box = "centos-lamp"

	# URL da box.
	config.vm.box_url = "https://www.dropbox.com/s/qajiajhgbm1tt68/centos64-64.box?dl=1"
 
  # definimos pasta do projeto
  sourcedir = "../lamp-development"

  # definimos o arquivo de configuração
  config_file = sourcedir + "/vagrant_config.yml" 

  # Incluímos o módulo utilitário de ler arquivos de configuração
  require 'yaml'

  # Primeiro verificamos se o arquivo existe.
  if File.exists? (config_file)
    # lemos o arquivo de configuração
    vconfig = YAML::load_file(config_file)
  else
    # Caso não exista, deixo as configurações como vazio.    
    vconfig = {} 
  end

  # definimos local do script de ajustes finos
  setupscript = "./scripts/setup.sh"

  # Capturamos o endereço ip do arquivo de configurações. 
  ip_host = vconfig['ip_host']

  # Caso não exista, é usado um ip padrão.
  if not ip_host
    ip_host = "192.168.2.10"
  end

  # definimos um ip para essa máquina (usando NAT aqui).
  config.vm.network :private_network, ip: ip_host

  # Redirecionamos a porta 8000 do guest para 8000 do host(apache)
  config.vm.network :forwarded_port, guest: 8000, host: 8000

  # Faz um túnel SSH
  config.ssh.forward_agent = true

  # Adicionamos pasta compartilhada "/var/www/html/dev"
  # Se o host for Linux, o compartilhamento é ativado com suporte a NFS(maior performance)
  if Vagrant::Util::Platform.windows?
    config.vm.synced_folder sourcedir, "/var/www/html/dev", :mount_options => ["dmode=777","fmode=777"], :owner => "vagrant", :group => "vagrant"
  else
    config.vm.synced_folder sourcedir, "/var/www/html/dev"
  end

  config.vm.provider :virtualbox do |vb|
    # esse é um bug conhecido ao usar NAT em alguns casos no virtualbox, ele fica sem dns
    # e pra resolver isso colocamos essa linha
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]

    # deixo a gui como false
    vb.gui = false
 
    # Colocando mais memoria e mudando o nome da maquina virtual
    #vb.customize ["modifyvm", :id, "--memory", 2048]
    #vb.customize ["modifyvm", :id, "--name", "epic.local.lamp.dev"]
    
    #Adicionando mais capacidade de execução na cpu
    #vb.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]

    #Adicionando mais núcleos
    #vb.customize ["modifyvm", :id, "--cpus", 2]
  end

    # desativa o SELinux(para evitar problemas com a porta 8000 do apache)
    config.vm.provision :shell, :inline =>
    "echo 0 >/selinux/enforce"
 
    # definindo configurações do puppet
    config.vm.provision :puppet do |puppet|
    
      # pasta onde fica seus manifests
      puppet.manifests_path = "manifests"

      # arquivo manifest que você quer que seja chamado de começo
      puppet.manifest_file  = "lamp.pp"
 
      # pasta onde ficam os modulos do puppet
      puppet.module_path = "./modules"

      # melhor logging do puppet na execução do vagrant, é bom pra debugar coisas
      puppet.options = "--verbose"
  end

  # Após executar os módulos do puppet, chamo o script para ajustes finos de configuração
  config.vm.provision "shell" do |s|

    # Indico o path para o shell script    
    s.path = setupscript

    # Capturo o nome do host
    host_name = vconfig['box_name']

    # Verifico se o parâmetro box_name não está vazio
    if not host_name
      s.args = "epic.local.dev"
    else
      s.args = vconfig['box_name']
    end

  end

end
