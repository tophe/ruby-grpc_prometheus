
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "grpc_prometheus/version"

Gem::Specification.new do |spec|
  spec.name          = "grpc_prometheus"
  spec.version       = GRPCPrometheus::VERSION
  spec.authors       = ["Yuya Takeyama"]
  spec.email         = ["sign.of.the.wolf.pentagram@gmail.com"]

  spec.summary       = %q{Monitor gRPC server}
  spec.description   = %q{Expose a Prometheus metric endpoint to monitor gRPC server}
  spec.homepage      = "https://github.com/yuya-takeyama/ruby-grpc_prometheus"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "grpc", "~> 1.7"
  spec.add_dependency "prometheus-client"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "grpc-tools"
end
