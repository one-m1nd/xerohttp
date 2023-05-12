# frozen_string_literal: true

RSpec.describe XeroHTTP do
  let(:url) { "https://www.ruby-lang.org/en/" }

  describe '.user_agent' do
    before(:each) do
      stub_request(:get, url).to_return(status: 200, body: 'Ruby')
    end

    subject { XeroHTTP.user_agent(value) }

    context 'sample GET request' do
      context 'value = JohnAgent' do
        let(:value) { 'JohnAgent' }

        it do
          subject.get(url)

          expect(
            a_request(:get, url).with(headers: { 'User-Agent' => value })
          ).to have_been_made
        end
      end
    end
  end

  describe '.filtered_logging' do
    before(:each) do
      stub_request(:get, url).to_return(status: 200, body: 'Ruby')
    end

    let(:filters) { [/^Authorization.*/] }

    subject { XeroHTTP.filtered_logging(Logger.new($stdout), filters: filters) }

    context 'sample GET request' do
      context 'when requesting with a sensitive header value' do
        it do
          expect do
            subject.auth('Secret omg do not see this').get(url)
          end.to_not output(/omg do not see this/).to_stdout

          expect(a_request(:get, url)).to have_been_made
        end
      end

      context 'when request content type is octet-stream' do
        before(:each) do
          stub_request(:get, url).to_return(status: 200, body: 'some data', headers: { 'Content-Type' => 'application/octet-stream' })
        end

        it do
          expect do
            subject.get(url)
          end.to_not output(/some data/).to_stdout

          expect(a_request(:get, url)).to have_been_made
        end
      end

      context 'when request content body is too long' do
        before(:each) do
          stub_request(:get, url).to_return(status: 200, body: 'some data', headers: { 'Content-Length' => 6666 })
        end

        it do
          expect do
            subject.get(url)
          end.to_not output(/some data/).to_stdout

          expect(a_request(:get, url)).to have_been_made
        end
      end
    end
  end

  describe '.download' do
    let(:dir) { Dir.mktmpdir }
    let(:file) { 'foo.bar' }
    let(:destination) { File.join(dir, file) }

    before(:each) do
      stub_request(:get, url).to_return(status: 200, body: 'some data', headers: { 'Content-Length' => 'some data'.length })
    end

    after(:each) do
      FileUtils.remove_dir(dir)
    end

    subject { XeroHTTP.download(url, destination) }

    it do
      subject

      expect(File.read(destination)).to eql('some data')
      expect(a_request(:get, url)).to have_been_made
    end

    context 'with block passed' do
      it do
        expect do |probe|
          XeroHTTP.download(url, destination, &probe)
        end.to yield_successive_args(instance_of(String))

        expect(a_request(:get, url)).to have_been_made
      end
    end
  end

  describe '.stream' do
    let(:io) { StringIO.new }

    before(:each) do
      stub_request(:get, url).to_return(status: 200, body: 'some data', headers: { 'Content-Length' => 'some data'.length })
    end

    subject { XeroHTTP.stream(url, io) }

    it do
      subject

      expect(io.string).to eql('some data')
      expect(a_request(:get, url)).to have_been_made
    end

    context 'with block passed' do
      it do
        expect do |probe|
          XeroHTTP.stream(url, io, &probe)
        end.to yield_successive_args(instance_of(String))

        expect(a_request(:get, url)).to have_been_made
      end
    end
  end
end
