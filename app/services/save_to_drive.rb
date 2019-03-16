require 'google/apis/script_v1'
require 'googleauth'
require_relative './env_token_store'

require 'json'
require 'fileutils'

SaveToDrive = Struct.new(:camp) do
  def perform
    return unless ENV['GOOGLE_APPS_NAME']
    if response.error
      puts "Script error message: #{response.error.details(0)['errorMessage']}"
      puts "Script error stacktrace:"
      response.error.details(0)['scriptStackTraceElements'].to_a.each do |trace|
        puts "\t#{trace['function']}: #{trace['lineNumber']}"
      end
    else
      camp.update(
        google_drive_folder_path:      response.response['result']['id'],
        google_drive_budget_file_path: response.response['result']['budget']
      )
      response.response['result']
    end
  rescue Google::Apis::ClientError => e
    puts "Error calling API!"
    puts "Caught error #{e}"
  end

  private

  def response
    @response ||= begin
      # Initialize the API
      service = Google::Apis::ScriptV1::ScriptService.new
      service.client_options.application_name = ENV["GOOGLE_APPS_NAME"]
      service.authorization = authorizer.get_credentials('default') || manual_authorize

      # Create an execution request object.
      request = Google::Apis::ScriptV1::ExecutionRequest.new(
        function: ENV['GOOGLE_APPS_SCRIPT_FUNCTION'],
        parameters: [camp.creator.email, camp.id, camp.name]
      )

      service.run_script(ENV['GOOGLE_APPS_SCRIPT'], request)
    end
  end

  def authorizer
    @authorizer ||= Google::Auth::UserAuthorizer.new(
      Google::Auth::ClientId.from_hash(JSON.parse(ENV['GOOGLE_CLIENT_SECRETS'])),
      'https://www.googleapis.com/auth/drive',
      ENVTokenStore.new('GOOGLE_APPS_SCRIPT_TOKEN')
    )
  end

  def manual_authorize
    puts "Open the following URL in the browser and enter the resulting code after authorization:"
    puts authorizer.get_authorization_url(base_url: 'urn:ietf:wg:oauth:2.0:oob')
    authorizer.get_and_store_credentials_from_code(
      user_id: 'default',
      code: gets,
      base_url: 'urn:ietf:wg:oauth:2.0:oob'
    )
  end
end
