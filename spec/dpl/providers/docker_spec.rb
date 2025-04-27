describe Dpl::Providers::Docker do
  let(:args) { |e| %w(--image image --target target --username user --password 12345) + args_from_description(e) }

  before { subject.run }

  describe 'by default', record: true do
    it { should have_run '[info] $ docker login --username user --password 1*******************' }
    it { should have_run 'docker login --username user --password 12345' }
    it { should have_run '[info] Building docker image image from .' }
    it { should have_run '[info] $ docker build . --no-cache -t image' }
    it { should have_run 'docker build . --no-cache -t image' }
    it { should have_run '[info] Tagging image image as target' }
    it { should have_run '[info] $ docker tag image target' }
    it { should have_run 'docker tag image target' }
    it { should have_run '[info] Pushing image target' }
    it { should have_run '[info] $ docker push target' }
    it { should have_run 'docker push target' }
    it { should have_run 'docker logout' }
    it { should have_run_in_order }
  end

  describe 'given --build_arg one=1 --build_arg two=2' do
    it { should have_run '[info] $ docker build . --no-cache -t image --build-arg="one=1" --build-arg="two=2"' }
  end
end
