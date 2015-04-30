module Topolegal
  class Expediente
    attr_accessor :estado, :juzgado, :fecha, :expediente, :descripcion

    def initialize(args)
      self.estado = args[:estado]
      self.juzgado = args[:juzgado]
      self.fecha = args[:fecha]
      self.expediente = args[:expediente]
      self.descripcion = args[:descripcion]
    end
  end
end
