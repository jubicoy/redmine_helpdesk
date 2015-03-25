module RedmineHelpdesk
  module MailHandlerPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :dispatch_to_default, :helpdesk
      end
    end

    module InstanceMethods
      private
      # Overrides the dispatch_to_default method to
      # set the owner-email of a new issue created by
      # an email request
      def dispatch_to_default_with_helpdesk

        # owner-email override is cleared and value cached if present
        @helpdesk_sender_email = get_keyword_with_reset(:"owner-email")
        issue = dispatch_to_default_without_helpdesk

        # Correct author is fetched based on overrides if present
        author = find_author(issue)
        roles = author.roles_for_project(issue.project)

        # add owner-email only if the author has assigned some role with
        # permission treat_user_as_supportclient enabled
        if roles.any? {|role| role.allowed_to?(:treat_user_as_supportclient) }
          if @helpdesk_sender_email.blank?
            @helpdesk_sender_email = @email.from.first
          end
          add_owner_email issue
          # regular email sending to known users is done
          # on the first issue.save. So we need to send
          # the notification email to the supportclient
          # on our own.
          notify_supportclient issue
        end
        after_dispatch_to_default_hook issue
        return issue
      end

      # let other plugins the chance to override this
      # method to hook into dispatch_to_default
      def after_dispatch_to_default_hook(issue)
      end

      def get_keyword_with_reset(attr, options={})
        k = get_keyword(attr, options)
        @keywords = nil
        rx = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        if rx.match(k)
          k
        else
          nil
        end
      end

      def find_author(issue)
        author = issue.author
        if !@helpdesk_sender_email.nil? && (a = User.find_by_mail(@helpdesk_sender_email))
          issue.update_attribute :author_id, a.id
          author = a
        end
        author
      end

      def add_owner_email(issue)
        custom_field = CustomField.find_by_name('owner-email')
        custom_value = CustomValue.where(
          "customized_id = ? AND custom_field_id = ?", issue.id, custom_field.id).
          first
        custom_value.value = @helpdesk_sender_email
        custom_value.save(:validate => false) # skip validation!
      end

      def notify_supportclient(issue)
        sfr = issue.project.custom_value_for(
            CustomField.find_by_name('helpdesk-send-first-reply'))
        if sfr.is_a?(CustomValue) && sfr.true?
          Mailer.email_to_supportclient(issue, @helpdesk_sender_email).deliver
        end
      end
    end # module InstanceMethods
  end # module MailHandlerPatch
end # module RedmineHelpdesk

# Add module to MailHandler class
MailHandler.send(:include, RedmineHelpdesk::MailHandlerPatch)
