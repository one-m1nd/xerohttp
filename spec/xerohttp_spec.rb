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

  describe '#filtered_logging' do
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
end
