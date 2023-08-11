# frozen_string_literal: true

# Silences "Struct::Tms is deprecated" warnings on Ruby 2.6.2 that would
# otherwise spam hundereds of warnings, on apparently every single const
# eager loaded (or something). The constant Tms is not used anywhere in
# the aws-sdk gem, so it seems safe to skip it.
#
# Maybe submit a patch to aws-sdk?

Aws::EagerLoader.class_eval do
  def load(klass_or_module)
    @loaded << klass_or_module
    klass_or_module.constants.each do |const_name|
      next if const_name == :Tms

      path = klass_or_module.autoload?(const_name)
      begin
        require(path) if path
        const = klass_or_module.const_get(const_name)
        self.load(const) if const.is_a?(Module) && !@loaded.include?(const)
      rescue LoadError
      end
    end
    self
  end
end
