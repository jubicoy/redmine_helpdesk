require File.dirname(__FILE__) + '/../test_helper'

class MacroExpanderTest < ActiveSupport::TestCase
  include Redmine::I18n

  self.use_transactional_fixtures = true

  fixtures :all

  def test_no_changes
    s = "test string"
    issue = Issue.find(1)
    journal = issue.journals.first

    assert_equal s, MacroExpander.expand(s, issue, journal)
  end

  def test_expand_issue
    s = "##issue-id## ##issue-subject## ##issue-tracker## ##issue-status## text"
    issue = Issue.find(1)
    journal = issue.journals.first

    assert_equal "#{issue.id} #{issue.subject} #{issue.tracker.name} #{issue.status.name} text",
      MacroExpander.expand(s, issue, journal)
  end

  def test_expand_project
    s = "##project-name## text"
    issue = Issue.find(1)
    journal = issue.journals.first

    assert_equal "#{issue.project.name} text",
      MacroExpander.expand(s, issue, journal)
  end

  def test_expand_user
    s = "##user-name## ##user-mail## text"
    issue = Issue.find(1)
    journal = issue.journals.first

    assert_equal "#{journal.user.name} #{journal.user.mail} text",
      MacroExpander.expand(s, issue, journal)
  end

  def test_expand_base
    s = "##time-now## text"

    assert_equal "#{I18n.l(Time.zone.now)} text",
      MacroExpander.expand(s)
  end
end
