module RenderMePretty
  class Context
    def initialize(hash={})
      # http://stackoverflow.com/questions/1338960/ruby-templates-how-to-pass-variables-into-inlined-erb
      hash.each do |key, value|
        instance_variable_set('@' + key.to_s, value)
      end
    end

    def override_variables!(vars)
      vars.each do |key, value|
        instance_variable_set('@' + key.to_s, value)
      end
    end

    def get_binding
      binding
    end

    def self.load_helpers(base_folder)
      Dir.glob("#{base_folder}/**/*_helper.rb").each do |path|
        relative_path = path.sub("#{base_folder}/", "")
        class_name = File.basename(relative_path, '.rb').classify

        require path
        include const_get(class_name)
      end
    end
  end
end
