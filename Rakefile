task :styles do
    sh 'sass styles:public/styles'
end

namespace :styles do
    task :watch do
        sh 'sass styles:public/styles --watch'
    end
end

task :default => :styles