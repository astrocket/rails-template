insert_into_file "config/application.rb", before: /^  end/ do
  <<-'RUBY'
    # Use sidekiq to process Active Jobs (e.g. ActionMailer's deliver_later)
    config.active_job.queue_adapter = :sidekiq
    config.middleware.use ::I18n::Middleware
    config.generators do |g|
      g.assets  false
      g.stylesheets false
    end

    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      html = ''

      form_fields = ['textarea', 'input', 'select']

      elements = Nokogiri::HTML::DocumentFragment.parse(html_tag).css "label, " + form_fields.join(', ')

      elements.each do |e|
        if e.node_name.eql? 'label'
          e['class'] = %(#{e['class']} invalid_field_label)
          html = %(#{e}).html_safe
        elsif form_fields.include? e.node_name
          if instance.error_message.kind_of?(Array)
            html = %(#{e}<p class="text-sm text-red-600">#{instance.error_message.uniq.join(', ')}</p>).html_safe
          else
            html = %(#{e}<p class="text-sm text-red-600">#{instance.error_message}</p>).html_safe
          end
        end
      end
      html
    end
  RUBY
end
