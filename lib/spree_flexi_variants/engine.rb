module SpreeFlexiVariants
  class Engine < Rails::Engine
    engine_name 'spree_flexi_variants'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      Spree::Core::Environment::Calculators.class_eval do
        attr_accessor :product_customization_types
      end
    end

    config.to_prepare &method(:activate).to_proc

    # Had a good reason for this rescue below, and wish I'd commented it better when I wrote it
    # TODO - figure this out and de-ugly
    begin
      initializer "spree.register.calculators" do |app|
        app.config.spree.calculators.add_class('product_customization_types')
        app.config.spree.calculators.product_customization_types = [
                                                                    Spree::Calculator::Engraving,
                                                                    Spree::Calculator::AmountTimesConstant,
                                                                    Spree::Calculator::ProductArea,
                                                                    Spree::Calculator::CustomizationImage
                                                                   ]
      end
    rescue => problem
      puts "intentionally ignoring problem in calculator registration #{problem}"
    end
  end
end
