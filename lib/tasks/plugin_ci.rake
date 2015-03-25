namespace :helpdesk do
  plugin_root = File.expand_path('../../../', __FILE__)
  coverage_dir = "#{plugin_root}/coverage"

  desc 'Runs Redmine plugin tests with single CodeClimate TestReporter invocation.'
  task :test => [ "helpdesk:test:clear_coverage_data",
                  "helpdesk:test:run" ]

  namespace :test do
    task :run do
      Rake::Task["redmine:plugins:test:units"].invoke
      Rake::Task["redmine:plugins:test:functionals"].invoke

      require "simplecov"
      require "codeclimate-test-reporter"
      SimpleCov.coverage_dir coverage_dir
      CodeClimate::TestReporter.configure do |config|
        config.git_dir = plugin_root
      end
      CodeClimate::TestReporter::Formatter.new.format(SimpleCov.result)
    end

    task :clear_coverage_data do
      rm_rf coverage_dir
    end
  end
end
