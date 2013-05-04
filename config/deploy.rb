require 'rvm/capistrano'
require 'sidekiq/capistrano'
require 'bundler/capistrano'

set :application, "hummingbird"
set :repository,  "git@github.com:vikhyat/hummingbird.git"

set :scm, :git
set :user, "vikhyat"
set :git_enable_submodules, 1
set :deploy_via, :remote_cache
set :rvm_type, :user

default_run_options[:pty] = true

server "hakanai", :app, :web, :db, primary: true
#role :db,  "your slave db-server here"

#
# CUSTOM TASKS
#

namespace :deploy do
  desc "stub task to get cap to prompt for the root password"
  task :sudo_prompt, roles: :web do
    run "#{sudo} ls"
  end

  desc "symlink nginx configuration"
  task :nginx_symlink, roles: :web do
    run "#{sudo} ln -nfs #{release_path}/config/nginx.conf /etc/nginx/sites-enabled/hummingbird"
  end

  desc "symlink riemann configuration"
  task :nginx_symlink, roles: :web do
    run "#{sudo} ln -nfs #{release_path}/config/riemann.config /home/vikhyat/Riemann/etc/riemann.config"
  end
  
  desc "reload nginx configuration"
  task :nginx_reload, roles: :web do
    run "#{sudo} service nginx reload"
  end
  
  desc "symlink monit configuration"
  task :monit_symlink, roles: :web do
    run "#{sudo} ln -nfs #{release_path}/config/monit.conf /etc/monit/conf.d/hummingbird.conf"
  end
  
  desc "reload monit configuration"
  task :monit_reload, roles: :web do
    run "#{sudo} monit reload"
  end
  
  desc "start the app"
  task :start, roles: :web do
    run "#{sudo} monit -g hummingbird start"
  end
  
  desc "stop the app"
  task :stop, roles: :web do
    run "#{sudo} monit -g hummingbird stop"
  end
  
  desc "reload unicorn"
  task :reload_unicorn, roles: :web do
    run "kill -USR2 `cat /u/apps/hummingbird/shared/pids/unicorn.pid`"
  end

  desc "kill extra sidekiq processes"
  task :kill_extra_sidekiqs, roles: :web do
    pids = capture("ps aux | grep sidekiq | grep hummingbird | grep busy | grep -v grep").split("\n").map {|x| x.split[1].strip }
    current_pid = [capture("cat /u/apps/hummingbird/shared/pids/sidekiq.pid").strip]
    pids -= current_pid
    pids.each do |pid|
      run "kill -SIGTERM #{pid}"
    end
  end

  desc "stop monit from monitoring sidekiq"
  task :stop_monit_sidekiq, roles: :web do
    run "#{sudo} monit unmonitor sidekiq"
  end
  
  desc "resume monit sidekiq monitoring "
  task :start_monit_sidekiq, roles: :web do
    run "#{sudo} monit monitor sidekiq"
  end
  
  namespace :assets do
    task :precompile, roles: :web, except: {no_release: true} do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run <<-CMD.compact
          cd -- #{latest_release} &&
          #{rake} RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} assets:precompile &&
          cp -- #{shared_path.shellescape}/assets/manifest.yml #{current_release.shellescape}/assets_manifest.yml
        CMD
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end
  
  task :copy_old_sitemap do
    run "if [ -e #{previous_release}/public/sitemap_index.xml.gz ]; then cp #{previous_release}/public/sitemap* #{current_release}/public/; fi"
  end

  task :refresh_sitemaps do
    run "cd #{latest_release} && RAILS_ENV=#{rails_env} rake sitemap:refresh"
  end
end

after "deploy:update_code", "deploy:copy_old_sitemap"

before "deploy", "deploy:sudo_prompt"

after "deploy:finalize_update",
  "deploy:nginx_symlink", "deploy:monit_symlink"

after "deploy:restart",
  "deploy:reload_unicorn",
  "deploy:nginx_reload", "deploy:monit_reload"

before "sidekiq:restart", "deploy:stop_monit_sidekiq"
after "sidekiq:restart", "deploy:start_monit_sidekiq"

after "deploy:migrate", "deploy:reload_unicorn"

# To keep only the last 5 releases:
# (Default is `set :keep_releases, 5`)
after "deploy:restart", "deploy:cleanup"
