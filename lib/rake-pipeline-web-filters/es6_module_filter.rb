module Rake::Pipeline::Web::Filters
  # A filter that transpiles ES6 to either AMD or CommonJS JavaScript.
  class ES6ModuleFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    # @return [Hash] a hash of options to pass to Transpiler
    attr_reader :options

    # By default, the ES6ModuleFilter converts all inputs
    # with the extension +.js+.
    #
    # @param [Hash] options options to pass to the Transpiler
    # @param [Proc] block the output name generator block
    def initialize(options = {}, &block)
      # probably delete
      block ||= proc { |input| input.sub(/\.coffee$/, '.js') }
      super(&block)
      @options = options
    end

    # The body of the filter. Compile each input file into
    # a ES6 Module Transpiled output file.
    #
    # @param [Array] inputs an Array of FileWrapper objects.
    # @param [FileWrapper] output a FileWrapper object
    def generate_output(inputs, output)
      inputs.each do |input|
        begin
          body = input.read if input.respond_to?(:read)
          output.write RubyES6ModuleTranspiler.transpile(body, @options)
        rescue ExecJS::Error => error
          raise error, "Error compiling #{input.path}. #{error.message}"
        end
      end
    end

    def external_dependencies
      [ "ruby_es6_module_transpiler" ]
    end
  end
end
