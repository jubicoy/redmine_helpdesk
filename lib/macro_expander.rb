class MacroExpander
  include Redmine::I18n

  def self.expand(string, issue=nil, journal=nil)
    return nil if string.nil?

    MacroExpander.new(string, issue, journal).expand
  end

  def initialize(string, issue, journal)
    @string = string
    @issue = issue
    @journal = journal
  end

  def expand
    unless @issue.nil?
      expand_issue
      expand_project
    end
    expand_user unless @journal.nil?
    expand_base

    @string
  end


  def expand_issue
    @string.gsub!("##issue-id##", @issue.id.to_s)
    @string.gsub!("##issue-subject##", @issue.subject)
    @string.gsub!("##issue-tracker##", @issue.tracker.name)
    @string.gsub!("##issue-status##", @issue.status.name)
  end

  def expand_project
    p = @issue.project
    @string.gsub!("##project-name##", p.name)
  end

  def expand_user
    u = @journal.user
    @string.gsub!("##user-name##", u.name)
    @string.gsub!("##user-mail##", u.mail)
  end

  def expand_base
    @string.gsub!("##time-now##", I18n.l(Time.zone.now))
  end
end
