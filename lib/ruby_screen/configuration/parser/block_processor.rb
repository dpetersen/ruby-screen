module RubyScreen::Configuration::Parser
  class BlockProcessor
    def initialize(preferences_hash, description)
      @preferences_hash, @description = preferences_hash, description

      process_directories
      extract_windows
      add_customizations
    end

    protected

    def process_directories
      if @preferences_hash.has_key?("working_directory")
        @description.working_directory = @preferences_hash.delete("working_directory")
      elsif @preferences_hash.has_key?("relative_directory")
        @description.append_directory(@preferences_hash.delete("relative_directory"))
      end
    end

    def extract_windows
      if @preferences_hash.has_key?("windows")
        @preferences_hash["windows"].each { |w| @description.add_window(w) }
        @preferences_hash.delete("windows")
      end
    end

    def add_customizations
      @preferences_hash.each do |k, v|
        # Necessary because YAML load takes values line 'on' or 'off' that aren't quoted and turn them into booleans
        if is_a_boolean?(v)
          v = (v ? "on" : "off")
        end

        @description.add_customization(k, v)
      end
    end

    def is_a_boolean?(value)
      value.is_a?(TrueClass) || value.is_a?(FalseClass)
    end
  end
end
