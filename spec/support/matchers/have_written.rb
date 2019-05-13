RSpec::Matchers.define :have_written do |path, str|
  match do
    str = str.chomp
    @file = File.read(File.expand_path(path)).chomp
    @file == str
  end

  failure_message do
    "Expected the file #{path} to contain:\n\n#{indent(str)}\n\nbut it contains:\n\n#{indent(@file)}"
  end

  def indent(str)
    str.lines.map { |line| ' ' * 4 + line }.join
  end
end
