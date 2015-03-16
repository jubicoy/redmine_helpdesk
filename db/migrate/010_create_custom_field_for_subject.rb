class CreateCustomFieldForSubject < ActiveRecord::Migration
  def self.up
    c = CustomField.new(
      :name => 'helpdesk-subject',
      :editable => true,
      :visible => false,          # do not show it on the project summary page
      :field_format => 'text')
    c.type = 'ProjectCustomField' # cannot be set by mass assignement!
    c.save
  end

  def self.down
    CustomField.find_by_name('helpdesk-subject').delete
  end
end
