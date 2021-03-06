module Shared::StackExchange
  class Processor
    class Users < Shared::StackExchange::Processor
      def process(filepath, options = {})
        user = Shared::User.find_by(id: -1)

        if user.nil?
          Shared::User.create_without_confirmation!(id: -1, login: :anonymous, email: 'anonymous@stackexchange.com', password: 'password', password_confirmation: 'password')
        end

        user = Shared::User.find_by(id: 0)

        if user.nil?
          Shared::User.create_without_confirmation!(id: 0, login: :community_wiki, email: 'community_wiki@stackexchange.com', password: 'password', password_confirmation: 'password')
        end

        parser = Nokogiri::XML::SAX::Parser.new(Document::Users.new)
        parser.parse(File.open(filepath))
      end
    end
  end
end
