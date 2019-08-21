RSpec::Matchers.define :have_zipped do |path, files|
  match do
    expect(File.exist?(path)).to be true
    zipped = Zip::File.open(path) { |zip| zip.glob('*').map(&:name) }
    @files = zipped - ['./']
    @files == files
  end

  failure_message do
    if File.exist?(path)
      "Expected the zip file #{path} to contain:\n\n#{indent(files)}\n\nbut it contains:\n\n#{indent(@files.join("\n"))}"
    else
      "Expected a zip file #{path} exist, but it doesn't"
    end
  end

  def indent(str)
    str.to_s.lines.map { |line| ' ' * 4 + line }.join
  end
end
