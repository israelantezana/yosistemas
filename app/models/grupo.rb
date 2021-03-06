class Grupo < ActiveRecord::Base
    
    belongs_to :usuario
    has_and_belongs_to_many :temas
    has_many :subscripcions
    has_and_belongs_to_many :tareas
    has_and_belongs_to_many :cuestionarios
    has_and_belongs_to_many :eventos
  
    delegate :nombre_usuario, :to => :usuario, :prefix => true
    
    validates :nombre, :presence => true
    validates :nombre, uniqueness: {case_sensitive: false, :message => ": Ya está en uso"}
    
    after_create :habilitar_grupo

    def self.privados
      Grupo.where(:estado => true)
    end

    def habilitar_grupo
      self.habilitado = true
      self.save
    end

    def deshabilitar_grupo
      self.habilitado = false
      self.save
    end

    def self.all_habilitados
      Grupo.where(:habilitado => true)
    end

    def usuario_suscrito?(id)
      resp = true
      for suscripcion in self.subscripcions
        if suscripcion.usuario_id == id
          return resp = false
        end
      end
      return resp
    end

    def correspondeAGrupo(nombre)
      parametros = nombre.split(' ')
      parametros.each do |parametro|
         if self.nombre.downcase.include?(parametro.downcase)
           return true
         end
      end
      false
    end

    def correspondeLlaveAGrupo(llave)
      parametros llave.split(' ')
      parametros.each do |parametro|
         if self.llave.downcase.include?(parametro.downcase)
           return true
         end
      end
      false
    end

    #genera un string aleatorio
    def generar_llave
      cadena = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    llave = (0...6).map{ cadena[rand(cadena.length)] }.join
    llave
    end

    def verificar_grupo
      if self.estado == true
        self.llave = generar_llave
      else
        self.llave = "publico"
      end
    end

    def self.buscar(grupo_id) 
      if grupo_id != nil && Grupo.find(grupo_id).habilitado
        grupo = Grupo.find(grupo_id)       
      else
        grupo = Grupo.obtener_grupo_publico
      end
    end

    def temas_aprobados
      temas_aprobados = Array.new
      temas.each do |tema|
        if tema.aprobado?(id) || llave == "publico"
          temas_aprobados << tema
        end
      end
      return temas_aprobados
    end

    def self.obtener_grupo_publico
      find_by_llave('publico')
    end
end
