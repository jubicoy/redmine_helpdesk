require File.dirname(__FILE__) + '/../test_helper'

class MailHandlerPatchTest < ActiveSupport::TestCase
  include Redmine::I18n

  self.use_transactional_fixtures = true

  fixtures :all

  def setup
    ActionMailer::Base.deliveries.clear
    Setting.notified_events = Redmine::Notifiable.all.collect(&:name)
  end

  def teardown
    Setting.clear_cache
  end

  def test_helpdesk_dispatch_not_supportclient
    Mailer.any_instance.expects(:email_to_supportclient).never
    issue = submit_email('ticket_by_user_1.eml',
                         :issue => {:project => 'helpdesk_project_1'},
                         :unknown_user => 'accept',
                         :no_permission_check => 1)
    assert_issue_created issue

    owner_field = CustomField.find_by_name('owner-email')
    owner_value = CustomValue.where(
      "customized_id = ? AND custom_field_id = ?", issue.id, owner_field.id).
      first
    assert owner_value.value.blank?
    assert User.find(1).login, issue.author.login
  end

  def test_helpdesk_dispatch_anonymous_as_supportclient
    assert_no_difference 'User.count' do
      Mailer.any_instance.expects(:email_to_supportclient).with(kind_of(Issue), "john.doe@somenet.foo").once
      issue = submit_email('ticket_by_unknown_user.eml',
                       :issue => {:project => 'helpdesk_project_1'},
                       :unknown_user => 'accept',
                       :no_permission_check => 1)
      assert_issue_created issue

      owner_field = CustomField.find_by_name('owner-email')
      owner_value = CustomValue.where(
          "customized_id = ? AND custom_field_id = ?", issue.id, owner_field.id).
          first
      assert_equal "john.doe@somenet.foo", owner_value.value
      assert issue.author.anonymous?
    end
  end

  def test_helpdesk_dispatch_supportclient
    Mailer.any_instance.expects(:email_to_supportclient).with(kind_of(Issue), User.find(2).mail)
    issue = submit_email('ticket_by_user_2.eml',
                         :issue => {:project => 'helpdesk_project_2'},
                         :unknown_user => 'accept',
                         :no_permission_check => 1)
    assert_issue_created issue

    owner_field = CustomField.find_by_name('owner-email')
    owner_value = CustomValue.where(
      "customized_id = ? AND custom_field_id = ?", issue.id, owner_field.id).
      first
    assert_equal User.find(2).mail, owner_value.value
    assert User.find(2).login, issue.author.login
  end

  def test_form_compat_override_block_respected_as_anonymous
    assert_no_difference 'User.count' do
      Mailer.any_instance.expects(:email_to_supportclient).with(kind_of(Issue), "form@somenet.foo").once
      issue = submit_email('form_compat_ticket_by_unknown_user_w_override.eml',
                       :issue => {:project => 'helpdesk_project_1'},
                       :unknown_user => 'accept',
                       :no_permission_check => 1)
      assert_issue_created issue

      owner_field = CustomField.find_by_name('owner-email')
      owner_value = CustomValue.where(
          "customized_id = ? AND custom_field_id = ?", issue.id, owner_field.id).
          first
      assert_equal "form@somenet.foo", owner_value.value
      assert issue.author.anonymous?
    end
  end

  def test_form_compat_owner_email_overriden_as_anonymous
    assert_no_difference 'User.count' do
      Mailer.any_instance.expects(:email_to_supportclient).with(kind_of(Issue), "john.doe@somenet.foo").once
      issue = submit_email('form_compat_ticket_by_unknown_user_w_override.eml',
                       :issue => {:project => 'helpdesk_project_1'},
                       :allow_override => 'owner-email',
                       :unknown_user => 'accept',
                       :no_permission_check => 1)
      assert_issue_created issue

      owner_field = CustomField.find_by_name('owner-email')
      owner_value = CustomValue.where(
          "customized_id = ? AND custom_field_id = ?", issue.id, owner_field.id).
          first
      assert_equal "john.doe@somenet.foo", owner_value.value
      assert issue.author.anonymous?
    end
  end

  def test_form_compat_override_block_respected_as_supportclient
    Mailer.any_instance.expects(:email_to_supportclient).with(kind_of(Issue), "form@somenet.foo")
    issue = submit_email('form_compat_ticket_by_user_2_w_override.eml',
                         :issue => {:project => 'helpdesk_project_1'},
                         :unknown_user => 'accept',
                         :no_permission_check => 1)
    assert_issue_created issue

    owner_field = CustomField.find_by_name('owner-email')
    owner_value = CustomValue.where(
      "customized_id = ? AND custom_field_id = ?", issue.id, owner_field.id).
      first

    assert_equal "form@somenet.foo", owner_value.value
    assert issue.author.anonymous?
  end

  def test_form_compat_owner_email_overriden_as_supportclient
    Mailer.any_instance.expects(:email_to_supportclient).with(kind_of(Issue), User.find(2).mail)
    issue = submit_email('form_compat_ticket_by_user_2_w_override.eml',
                         :issue => {:project => 'helpdesk_project_2'},
                         :allow_override => 'owner-email',
                         :unknown_user => 'accept',
                         :no_permission_check => 1)
    assert_issue_created issue

    owner_field = CustomField.find_by_name('owner-email')
    owner_value = CustomValue.where(
      "customized_id = ? AND custom_field_id = ?", issue.id, owner_field.id).
      first
    assert_equal User.find(2).mail, owner_value.value
    assert User.find(2).login, issue.author.login
  end

  def test_form_compat_owner_email_not_set_if_not_supportclient
    Mailer.any_instance.expects(:email_to_supportclient).never
    issue = submit_email('form_compat_ticket_by_user_1_w_override.eml',
                         :issue => {:project => 'helpdesk_project_1'},
                         :allow_override => 'owner-email',
                         :unknown_user => 'accept',
                         :no_permission_check => 1)
    assert_issue_created issue

    owner_field = CustomField.find_by_name('owner-email')
    owner_value = CustomValue.where(
      "customized_id = ? AND custom_field_id = ?", issue.id, owner_field.id).
      first
    assert owner_value.value.blank?
    assert User.find(1).login, issue.author.login
  end

  def test_first_reply_not_sent_when_send_first_reply_false
    Mailer.any_instance.expects(:email_to_supportclient).never
    send_first_reply_field = CustomField.find_by_name('helpdesk-send-first-reply')
    send_first_reply_value = CustomValue.where(
      "customized_id = ? AND custom_field_id = ?", Project.find(1),
      send_first_reply_field.id).first
    send_first_reply_value.value = "0"
    send_first_reply_value.save!

    issue = submit_email('ticket_by_unknown_user.eml',
                     :issue => {:project => 'helpdesk_project_1'},
                     :unknown_user => 'accept',
                     :no_permission_check => 1)
    assert_issue_created issue

    owner_field = CustomField.find_by_name('owner-email')
    owner_value = CustomValue.where(
        "customized_id = ? AND custom_field_id = ?", issue.id, owner_field.id).
        first
    assert_equal "john.doe@somenet.foo", owner_value.value
    assert issue.author.anonymous?
  end

  def submit_email(filename, options={})
    raw = IO.read(File.join(TestHelper.files_path, 'mail_handler', filename))
    yield raw if block_given?
    MailHandler.receive(raw, options)
  end

  def assert_issue_created(issue)
    assert issue.is_a?(Issue), issue.class.name
    assert !issue.new_record?, "Given issue is not new record"
    issue.reload
  end
end
