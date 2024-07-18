module Bet
  module BetCalculations
    module Core
      { single: 1, double: 2, treble: 3 }.each do |ord, n|
        define_method(ord) do |prices, opts = {}|
          prices = parse_prices(prices)
          raise ArgumentError, "Wrong number of prices (#{prices.size} for #{n})" if prices.size != n
          acca(prices, opts)
        end
      end

      def accumulator(prices, opts = {})
        prices = parse_prices(prices)
        opts   = parse_opts(opts)
        
        return send("ew_#{__method__}") if opts[:ew]

        returns = c(opts[:stake], prices.reduce(:*))
        profit  = returns - opts[:stake]

        {
          returns: returns,
          profit: profit,
          outlay: opts[:stake]
        }
      end
      alias_method :acca, :accumulator
      alias_method :parlay, :accumulator
    end
  end
end