require 'rspec/core/rake_task'

task :folder_A do

  RSpec::Core::RakeTask.new(:spec) do |t|

    t.pattern = 'spec/folder_A/*/_spec.rb'

  end

  Rake::Task["spec"].execute
end

task :default do

  RSpec::Core::RakeTask.new(:spec)
  Rake::Task["spec"].execute
  
end
