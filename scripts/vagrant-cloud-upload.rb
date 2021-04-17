require "net/http"
require "http"
require "logger"

box_name=ARGV[0]
version=ENV["X_MIE_VERSION"]

base_url="https://app.vagrantup.com/api/v1/box/breeze/#{box_name}"

http = HTTP.use(logging: {logger: Logger.new(STDOUT, level: :info)})
    .timeout(connect: 60, write: 60, read: 60)
api = http.auth("Bearer #{ENV['VAGRANT_CLOUD_ACCESS_TOKEN']}")

response = api.get("#{base_url}/version/#{version}")

if ! response.status.success?
    response = api.post("#{base_url}/versions", json: {
        version: {
            version: version,
            description: ""
        }
    })

    if ! response.status.success?
        raise "Could not create version. code: #{response.code}."
    end
end

response = api.get("#{base_url}/version/#{version}/provider/virtualbox")
if ! response.status.success?
    response = api.post("#{base_url}/version/#{version}/providers", json: {
        provider: {
            name: "virtualbox"
        }
    })

    if ! response.status.success?
        raise "Could not create provider. code: #{response.code}."
    end
end

download_url = response.parse["download_url"]
response = http.follow.get(download_url)

if ! response.status.success?

    for i in 0..5
        response = api.get("#{base_url}/version/#{version}/provider/virtualbox/upload")

        if ! response.status.success?
            raise "Could not initiate upload. code: #{response.code}."
        end

        upload_path = response.parse["upload_path"]
        uri = URI(upload_path)
        file = File.open("#{box_name}.box")
        nethttp = Net::HTTP.new(uri.host, uri.port)
        nethttp.use_ssl = true
        nethttp.open_timeout = 1200
        nethttp.read_timeout = 1200
        nethttp.ssl_timeout = 1200
        nethttp.write_timeout = 1200
        request = Net::HTTP::Put.new(uri)
        request["Content-Length"] = "#{file.size}"
        request.body_stream = file
        response = nethttp.request(request)

        if "#{response.code}" == "499"
            for i in 0..5
                sleep 60
                response = http.follow.get(download_url)
                if response.status.success?
                    break
                end
            end
        end

        if "#{response.code}" == "200"
            break
        end
    end

    if "#{response.code}" != "200"
        raise "Could not upload file. code: #{response.code}."
    end

end

response = api.put("#{base_url}/version/#{version}/release")
if ! response.status.success?
    raise "Could not release version. code: #{response.code}."
end
