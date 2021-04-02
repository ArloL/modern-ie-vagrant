require "http"
require "logger"

box_name=ARGV[0]
version=ENV["X_MIE_VERSION"]

base_url="https://app.vagrantup.com/api/v1/box/breeze/#{box_name}"

http = HTTP.use(logging: {logger: Logger.new(STDOUT, level: :info)})
api = http.auth("Bearer #{ENV['VAGRANT_CLOUD_ACCESS_TOKEN']}")

response = api.post("#{base_url}/versions", json: {
    version: {
        version: version,
        description: ""
    }
})

if ! response.status.success?
    raise "Could not create version. code: #{response.code}."
end

response = api.post("#{base_url}/version/#{version}/providers", json: {
  provider: {
    name: "virtualbox"
  }
})

if ! response.status.success?
    raise "Could not create provider. code: #{response.code}."
end

response = api.get("#{base_url}/version/#{version}/provider/virtualbox/upload")

if ! response.status.success?
    raise "Could not initiate upload. code: #{response.code}."
end

upload_path = response.parse["upload_path"]
response = http.put upload_path, body: File.open("#{box_name}.box")

if ! response.status.success?
    raise "Could not upload file. code: #{response.code}."
end

response = api.put("#{base_url}/version/#{version}/release")
if ! response.status.success?
    raise "Could not release version. code: #{response.code}."
end
