module Arel
  class Session
    class << self
      attr_accessor :instance
      alias_method :manufacture, :new

      def start
        if @started
          yield
        else
          begin
            @started = true
            @instance = manufacture
            metaclass.send :alias_method, :new, :instance
            yield
          ensure
            metaclass.send :alias_method, :new, :manufacture
            @started = false
          end
        end
      end
    end

    module CRUD
      def create(insert)
        insert.call
        insert
      end

      def read(select)
        (@read ||= Hash.new do |hash, select|
          hash[select] = select.call
        end)[select]
      end

      def update(update)
        update.call
      end

      def delete(delete)
        delete.call
      end
    end
    include CRUD
  end
end
