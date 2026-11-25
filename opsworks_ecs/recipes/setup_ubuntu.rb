# Docker's official apt repository. The old apt.dockerproject.org repository
# (docker-engine packages) has been shut down.
file "/etc/apt/sources.list.d/docker.list" do
  content "deb #{node["opsworks_ecs"]["ubuntu_docker_repository"]["url"]} #{node["lsb"]["codename"]} #{node["opsworks_ecs"]["ubuntu_docker_repository"]["component"]}"
end

key_file = "#{Chef::Config[:file_cache_path]}/#{node["opsworks_ecs"]["ubuntu_docker_repository"]["fingerprint"]}.pubkey"
cookbook_file key_file do
  source "#{node["opsworks_ecs"]["ubuntu_docker_repository"]["fingerprint"]}.pubkey"
end

execute "Import docker repository key" do
  command "apt-key add #{key_file}"

  not_if do
    OpsWorks::ShellOut.shellout("apt-key adv --list-public-keys #{node["opsworks_ecs"]["ubuntu_docker_repository"]["fingerprint"]}") rescue false
  end
end

execute "apt-get update"

package "docker-ce" do
  retries 3
  retry_delay 5
  options "--no-install-recommends"
end
