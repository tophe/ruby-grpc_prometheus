require 'prometheus/client'
require 'prometheus/client/formats/text'
require 'webrick'

module GRPCPrometheus
  class ServerMetrics
    attr_accessor :server_started_counter,
                :server_handled_counter,
                  :summary

    def initialize
      @registry = ::Prometheus::Client.registry
      @server_started_counter = Prometheus::Client::Counter.new(
        :grpc_server_started_total,
        docstring: 'Total number of RPCs started on the server.',
      labels: [:grpc_service, :grpc_method, :grpc_type]
      )

      @registry.register(@server_started_counter)


      @server_handled_counter = Prometheus::Client::Counter.new(
        :grpc_server_handled_total,
        docstring: 'Total number of RPCs completed on the server, regardless of success or failure.',
       labels: [:grpc_service, :grpc_method, :grpc_type, :grpc_code]
      )
      @registry.register(@server_handled_counter)


      @summary = Prometheus::Client::Summary.new(:service_latency_seconds, docstring: 'latency in ms',
                                                 labels: [:grpc_service, :grpc_method, :grpc_type, :grpc_code])

      @registry.register(@summary)


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

    def start_metric_endpoint_in_background(bind: '0.0.0.0', port: 19191, metrics_path: '/metrics')
      config = {
        BindAddress: bind,
        Port: port,
        MaxClients: 5,
        Logger: ::WEBrick::Log.new(STDERR, ::WEBrick::Log::FATAL),
        AccessLog: [],
      }
      server = ::WEBrick::HTTPServer.new(config)
      server.mount(metrics_path, MonitorServlet, @registry)
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
