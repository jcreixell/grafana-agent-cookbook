#
# Cookbook:: grafana-agent
# Recipe:: default
#
# Copyright:: 2024, The Authors, All Rights Reserved.

if platform_family?('debian', 'rhel', 'amazon', 'fedora')
  if platform_family?('debian')
    remote_file '/usr/share/keyrings/grafana.key' do
      source 'https://apt.grafana.com/gpg.key'
      mode '0644'
      action :create
      end
      
    file '/etc/apt/sources.list.d/grafana.list' do
      content "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com/ stable main"
      mode '0644'
      notifies :update, 'apt_update[update apt cache]', :immediately
    end
      
    apt_update 'update apt cache' do
      action :nothing
    end
  elsif platform_family?('rhel', 'amazon', 'fedora')
    yum_repository 'grafana' do
      description 'grafana'
      baseurl 'https://packages.grafana.com/oss/rpm'
      gpgcheck true
      gpgkey 'https://packages.grafana.com/gpg.key'
      enabled true
      action :create
      notifies :run, 'execute[add-rhel-key]', :immediately
    end
    
    execute 'add-rhel-key' do
      command "rpm --import https://packages.grafana.com/gpg.key"
      action :nothing
    end
  end

  package 'grafana-agent-flow' do
      action :install
      flush_cache [ :before ] if platform_family?('amazon', 'rhel', 'fedora')
      notifies :restart, 'service[grafana-agent-flow]', :delayed
  end

  service 'grafana-agent-flow' do
    service_name 'grafana-agent-flow'
    action [:enable, :start]
  end  
else
    fail "The #{node['platform_family']} platform is not supported."
end
