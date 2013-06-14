module Paperclip
  class HasAttachedFile
    def self.define_on(klass, name, options)
      new(klass, name, options).define
    end

    def initialize(klass, name, options)
      @klass = klass
      @name = name
      @options = options
    end

    def define
      define_flush_errors
      define_getter
      define_setter
      define_query
      check_for_path_clash
      register_with_rake_tasks
    end

    private

    def define_flush_errors
      @klass.send(:validates_each, @name) do |record, attr, value|
        attachment = record.send(@name)
        attachment.send(:flush_errors)
      end
    end

    def define_getter
      name = @name
      options = @options

      @klass.send :define_method, @name do |*args|
        ivar = "@attachment_#{name}"
        attachment = instance_variable_get(ivar)

        if attachment.nil?
          attachment = Attachment.new(name, self, options)
          instance_variable_set(ivar, attachment)
        end

        if args.length > 0
          attachment.to_s(args.first)
        else
          attachment
        end
      end
    end

    def define_setter
      name = @name

      @klass.send :define_method, "#{@name}=" do |file|
        send(name).assign(file)
      end
    end

    def define_query
      name = @name

      @klass.send :define_method, "#{@name}?" do
        send(name).file?
      end
    end

    def check_for_path_clash
      Paperclip.check_for_path_clash(@name, @options[:path], @klass.name)
    end

    def register_with_rake_tasks
      Paperclip::Tasks::Attachments.add(@klass, @name, @options)
    end
  end
end
