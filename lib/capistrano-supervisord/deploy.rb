require 'erb'

module Capistrano
  module Supervisord
    def self.extended(configuration)
      configuration.load {
        namespace(:deploy) {
          desc("Start service.")
          task(:start, :roles => :app, :except => { :no_release => true }) {
            supervisord.start
          }

          desc("Stop service.")
          task(:stop, :roles => :app, :except => { :no_release => true }) {
            supervisord.stop
          }

          desc("Restart service.")
          task(:restart, :roles => :app, :except => { :no_release => true }) {
            supervisord.restart
          }
        }

        namespace(:supervisord) {
          _cset(:supervisord_configure_path, '/')
          _cset(:supervisord_configure_source_path, File.join(File.dirname(__FILE__), 'templates', 'supervisord'))
          _cset(:supervisord_configure_files, [])
          _cset(:supervisord_configure_cleanup_files, [])

          _cset(:supervisord_install_method, :apt)
          _cset(:supervisord_service_method, :sysvinit)

          namespace(:setup) {
            desc("Setup supervisord.")
            task(:default, :roles => :app, :except => { :no_release => true }) {
              transaction {
                install.install
                configure
                service.install
                reload
              }
            }
            after 'deploy:setup', 'supervisord:setup'

            task(:configure, :roles => :app, :except => { :no_release => true }) {
              tmp_files = []
              on_rollback {
                run("rm -f #{tmp_files.join(' ')}") unless tmp_files.empty?
              }
              supervisord_configure_files.each { |file|
                src_file = File.join(supervisord_configure_source_path, file)
                dst_file = File.join(supervisord_configure_path, file)
                tmp_file = File.join('/tmp', File.basename(file))
                if File.file?(src_file)
                  put(File.read(src_file), tmp_file)
                elsif File.file?("#{src_file}.erb")
                  src_file = "#{src_file}.erb"
                  put(ERB.new(File.read(src_file)).result(binding), tmp_file)
                else
                  abort("configure: no such template found: #{src_file} or #{src_file}.erb")
                end
                run("diff -u #{dst_file} #{tmp_file} || #{sudo} mv -f #{tmp_file} #{dst_file}; rm -f #{tmp_file}")
              }
              run("#{sudo} rm -rf #{supervisord_configure_cleanup_files.join(' ')}") unless supervisord_configure_cleanup_files.empty?
            }
          }

          namespace(:install) {
            task(:default, :roles => :app, :except => { :no_release => true }) {
              install
            }

            task(:install, :roles => :app, :except => { :no_release => true }) {
              __send__(supervisord_install_method).install if supervisord_install_method
            }

            namespace(:apt) {
              _cset(:supervisord_install_apt_packages, %w(supervisor))
              task(:install, :roles => :app, :except => { :no_release => true }) {
                run("#{sudo} apt-get -y install #{supervisord_install_apt_packages.join(' ')}")
              }
            }
          }

          namespace(:service) {
            _cset(:supervisord_service_name, 'supervisor')
            task(:install, :roles => :app, :except => { :no_release => true }) {
              __send__(supervisord_service_method).install if supervisord_service_method
            }

            namespace(:sysvinit) {
              task(:install, :roles => :app, :except => { :no_release => true }) {
                # nop
              }

              task(:start, :roles => :app, :except => { :no_release => true }) {
                run("#{sudo} service #{supervisord_service_name} start")
              }

              task(:stop, :roles => :app, :except => { :no_release => true }) {
                run("#{sudo} service #{supervisord_service_name} stop")
              }

              task(:status, :roles => :app, :except => { :no_release => true }) {
                run("#{sudo} service #{supervisord_service_name} status")
              }

              task(:restart, :roles => :app, :except => { :no_release => true }) {
                run("#{sudo} service #{supervisord_service_name} restart || #{sudo} service #{supervisord_service_name} start")
              }

              task(:reload, :roles => :app, :except => { :no_release => true }) {
                run("#{sudo} service #{supervisord_service_name} force-reload || #{sudo} service #{supervisord_service_name} start")
              }
            }

            namespace(:upstart) {
              task(:install, :roles => :app, :except => { :no_release => true }) {
                run("#{sudo} update-rc.d -f #{supervisord_service_name} remove; true")
              }

              task(:start, :roles => :app, :except => { :no_release => true }) {
                run("#{sudo} service #{supervisord_service_name} start")
              }

              task(:stop, :roles => :app, :except => { :no_release => true }) {
                run("#{sudo} service #{supervisord_service_name} stop")
              }

              task(:status, :roles => :app, :except => { :no_release => true }) {
                run("#{sudo} service #{supervisord_service_name} status")
              }

              task(:restart, :roles => :app, :except => { :no_release => true }) {
                run("#{sudo} service #{supervisord_service_name} restart || #{sudo} service #{supervisord_service_name} start")
              }

              task(:reload, :roles => :app, :except => { :no_release => true }) {
                run("#{sudo} service #{supervisord_service_name} reload || #{sudo} service #{supervisord_service_name} start")
              }
            }
          }

          desc("Start supervisord daemon.")
          task(:start, :roles => :app, :except => { :no_release => true }) {
            service.__send__(supervisord_service_method).start if supervisord_service_method
          }

          desc("Stop supervisord daemon.")
          task(:stop, :roles => :app, :except => { :no_release => true }) {
            service.__send__(supervisord_service_method).stop if supervisord_service_method
          }

          desc("Restart supervisord daemon.")
          task(:restart, :roles => :app, :except => { :no_release => true }) {
            service.__send__(supervisord_service_method).restart if supervisord_service_method
          }

          desc("Reload supervisord daemon.")
          task(:reload, :roles => :app, :except => { :no_release => true }) {
            service.__send__(supervisord_service_method).reload if supervisord_service_method
          }

          desc("Show supervisord daemon status.")
          task(:status, :roles => :app, :except => { :no_release => true }) {
            service.__send__(supervisord_service_method).status if supervisord_service_method
          }
        }
      }
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.extend(Capistrano::Supervisord)
end

# vim:set ft=ruby :
