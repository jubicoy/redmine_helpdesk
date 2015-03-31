class CreateCustomFieldForSendFirstReply < ActiveRecord::Migration
  def self.up
    c = CustomField.new(
      :name => 'helpdesk-send-first-reply',
      :editable => true,
      :visible => false,          # do not show it on the project summary page
      :field_format => 'bool',
      :default_value => '1')
    c.type = 'ProjectCustomField' # cannot be set by mass assignement!
    c.save
  end

  def self.down
    CustomField.find_by_name('helpdesk-send-first-reply').delete
  end
end
