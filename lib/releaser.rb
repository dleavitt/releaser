require "releaser/version"
require 'rugged'
require 'forwardable'

module Releaser
  class ChangeLog
    attr_accessor :tag, :commits, :repo

    def initialize(repo, tag, commits)
      @repo, @tag, @commits = repo, tag, commits
    end

    def name
      tag.name
    end

    def jira_prefix
      repo.repo.config['releaser.jira.prefix']
    end

    def jira_url
      repo.repo.config['releaser.jira.url']
    end

    def format
      lines = ["Release #{name}: #{tag.time}"]
      lines << "\nTickets Resolved:"
      tickets.each do |t|
        lines << " * #{t} - #{jira_url}/browse/#{t}"
      end

      lines << "\nCommits:"
      commits.each do |c|
        author = c.author[:name]
        message = c.message.split("\n")[0]
        lines << " * [#{author}] #{message} (#{c.oid[0..8]})"
      end
      lines.join("\n")
    end

    def tickets
      @tickets ||= Set.new(commits.flat_map { |c|
        c.message.match(/#{jira_prefix}-\d+/) { |m| m && m[0] }
      }.compact)
    end
  end

  class Repo
    attr_accessor :repo

    def initialize(path = '.')
      @repo = Rugged::Repository.new(Rugged::Repository.discover(path))
    end

    def tags
      @tags ||= repo.tags.map do |tagname|
        rev = repo.rev_parse(tagname)
        commit = rev.respond_to?(:target) ? rev.target : rev
        Tag.new(tagname, commit)
      end.sort_by(&:time).reverse
    end

    def create_release(tag_name)
      Rugged::Reference.create(repo, "refs/tags/#{tag_name}", repo.last_commit.oid)
    end

    def last_change_log
      raise "Not enough tags in repo" if tags.length < 1

      # Need at least one tag in the repo (two if it's the current commit)
      if tags.first.oid == repo.last_commit.oid
        start_tag = tags.first
        end_tag = tags[1]
      else
        start_tag = Tag.new("HEAD", repo.last_commit)
        end_tag = tags[0]
      end

      ChangeLog.new(self, start_tag, commits_between(repo.last_commit, end_tag.commit))
    end

    def all_change_logs
      start_tag = Tag.new("HEAD", repo.last_commit)
      start_on = start_tag.oid == tags.first.oid ? nil : start_tag

      change_logs = []
      tags.reduce(start_on) do |start_tag, end_tag|
        if start_tag
          commits = commits_between(start_tag.commit, end_tag.commit)
          change_logs << ChangeLog.new(self, start_tag, commits)
        end
        end_tag
      end

      change_logs
    end

    def commits_between(start_ref, end_ref)
      commits = []
      repo.walk(start_ref.oid) do |commit|
        break if commit.oid == end_ref.oid
        commits << commit
      end

      commits
    end
  end

  Tag = Struct.new(:name, :commit) do
    extend Forwardable

    def_delegators :commit, :time, :message, :oid

    def author
      commit.author[:name]
    end
  end
end
