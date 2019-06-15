# GRPCPrometheus

Export a metric endpoint of gRPC services in Ruby for Prometheus.

This aims to behave basically the same as [grpc-ecosystem/go-grpc-prometheus](https://github.com/grpc-ecosystem/go-grpc-prometheus)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grpc_prometheus'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grpc_prometheus

## Usage

This gem collect metrics from a server interceptor.

```rb
# Create an instance of server metrics
metrics = GRPCPrometheus::ServerMetrics.new
# Launch a web server to expose the metric endpoint using WEBrick.
# All of the arguments are default values (you can omit them).
metrics.start_metric_endpoint_in_background(bind: '0.0.0.0', port: 19191, metrics_path: '/metrics')

# Create a gRPC server with server interceptor of server metrics
server = GRPC::RpcServer.new(interceptors: [metrics.server_interceptor])
server.add_http2_port('0.0.0.0:3000', :this_port_is_insecure)
server.handle(UsersService)
# Pre-register 0 to metrics for every methods and error codes
metrics.initialize_metrics(server)
server.run_till_terminated
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yuya-takeyama/ruby-grpc_prometheus. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GRPCPrometheus project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/yuya-takeyama/ruby-grpc_prometheus/blob/master/CODE_OF_CONDUCT.md).
