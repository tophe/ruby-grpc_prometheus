require 'prometheus/client'
require 'prometheus/client/formats/text'
require 'webrick'

module GRPCPrometheus
  class ServerMetrics
    attr_reader :server_started_counter,
                :server_handled_counter

    def initialize
      @registry = ::Prometheus::Client.registry
      @server_started_counter = @registry.counter(
        :grpc_server_started_total,
        'Total number of RPCs started on the server.',
      )
      @server_handled_counter = @registry.counter(
        :grpc_server_handled_total,
        'Total number of RPCs completed on the server, regardless of success or failure.',
      )
    end

    def server_interceptor
      ServerInterceptor.new(self)
    end

    def initialize_metrics(server)
      # FIXME
      server.instance_variable_get(:@rpc_descs).each do |full_method_name, method_info|
        matches = full_method_name.match(%r{^/([^/]+)/})
        service_name = matches[1]
        method_name = matches[2]
        pre_register_method(service_name, method_info)
      end
    end

    def pre_register_method(service_name, method_info)
      labels = {
        grpc_service: service_name,
        grpc_method: method_info.name.to_s,
        grpc_type: Util.type_from_method_info(method_info),
      }
      server_started_counter.increment(labels, 0)
      Util::ALL_CODES.each do |code, code_as_str|
        labels_with_code = labels.dup.merge({ grpc_code: code_as_str })
        server_handled_counter.increment(labels_with_code, 0)
      end
    end

    def start_metric_endpoint_in_background
      config = {
        BindAddress: '0.0.0.0',
        Port: 24231,
        MaxClients: 5,
        Logger: ::WEBrick::Log.new(STDERR, ::WEBrick::Log::FATAL),
        AccessLog: [],
      }
      server = ::WEBrick::HTTPServer.new(config)
      server.mount('/metric', MonitorServlet, @registry)
      Thread.start do
        server.start
      end
    end

    class MonitorServlet < ::WEBrick::HTTPServlet::AbstractServlet
      def initialize(server, registry)
        @registry = registry
      end

      def do_GET(req, res)
        res.status = 200
        res['Content-Type'] = ::Prometheus::Client::Formats::Text::CONTENT_TYPE
        res.body = ::Prometheus::Client::Formats::Text.marshal(@registry)
      rescue
        res.status = 500
        res['Content-Type'] = 'text/plain'
        res.body = $!.to_s
      end
    end
  end
end
