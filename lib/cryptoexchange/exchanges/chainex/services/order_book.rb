module Cryptoexchange::Exchanges
  module Chainex
    module Services
      class OrderBook < Cryptoexchange::Services::Market
        class << self
          def supports_individual_ticker_query?
            true
          end
        end

        def fetch(market_pair)
          output = super(ticker_url(market_pair))
          adapt(output['data'], market_pair)
        end

        def ticker_url(market_pair)
          "#{Cryptoexchange::Exchanges::Chainex::Market::API_URL}/market/orders/#{market_pair.base}/#{market_pair.target}/ALL/200"
        end

        def adapt(output, market_pair)
          order_book = Cryptoexchange::Models::OrderBook.new

          order_book.base      = market_pair.base
          order_book.target    = market_pair.target
          order_book.market    = Chainex::Market::NAME
          order_book.asks      = adapt_orders output[1]['orders']
          order_book.bids      = adapt_orders output[0]['orders']
          order_book.timestamp = nil
          order_book.payload   = output
          order_book
        end

        def adapt_orders(orders)
          orders.collect do |order_entry|
            Cryptoexchange::Models::Order.new(
             price: order_entry['price'],
             amount: order_entry['amount']
            )
          end
        end
      end
    end
  end
end
