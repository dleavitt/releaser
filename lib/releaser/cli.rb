require 'thor'
require 'releaser'

module Releaser
  class CLI < Thor
    include Thor::Actions

    desc "log", "Changelog between current HEAD and last tag"
    def log
      check_for_repo_config
      say repo.last_change_log.format
    end

    desc "full_log", "Changelog between all tags"
    def full_log
      check_for_repo_config
      say repo.all_change_logs.map(&:format).join("\n\n")
    end

    desc "release [tag]", "Create a tag"
    def release(tag)
      repo.create_release(tag)
      log
    end

    no_commands do
      def check_for_repo_config
        keys = {
          "releaser.jira.prefix" => "What is the JIRA project slug (eg HYFN, GS, AVON)",
          "releaser.jira.url" => "What is your JIRA base URL (eg https://company.atlassian.net)",
        }

        keys.each do |key, prompt|
          repo.repo.config[key] = ask prompt unless repo.repo.config[key]
        end
      end

      def repo
        @repo ||= Repo.new
      end
    end
  end
end
