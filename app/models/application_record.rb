insert_into_file 'app/models/application_record.rb', before: /^end/ do
  <<-'RUBY'
    def self.has?(record)
      raise Exception, "You passed #{record.class.name} to #{self.name} collection in has? method." and return if self.name != record.class.name
      all.where(id: record.id).exists?
    end
  RUBY
end