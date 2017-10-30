# /bin/irb.rb
# load 'asp.rb'
# asp = Asp.new(true, 'id + id')
# asp.iniciar
# O load 'asp.rb'; asp = Asp.new(true, '+ i + i'); asp.iniciar
# load 'asp-sync.rb'; asp = Asp.new(true, '+ id + id'); asp.iniciar
# el simbolo % representa al vacio
# el simbolo ~ es el caracter para representar el sync
#load 'tdata.rb'; load 'nickname.rb'

require './tdata.rb'
require './nickname.rb'
class Asp
  include ModuleTdata
  include ModuleNickname
  attr_accessor :tabla
  attr_accessor :no_terminales
  attr_accessor :simbolos_de_entrada
  attr_accessor :testing

  def initialize(testing=false,testing_entrada=nil)
    @show_translating = false
    @testing = testing
    @testing_entrada = testing_entrada
    @tabla = {}
    @no_terminales = []
    @simbolos_de_entrada = []
    @nicknames = {}
    @entrada = ''
    @errores = []
    @pila = []
    @x = ''
    @producciones_realizadas = []
  end

  def leer_no_terminales()
    puts "## Ingrese los no terminales ##"
    puts "_________________________________________"
    algo_mas = true

    while algo_mas
      #pedir o leer no terminales
      puts 'Ingrese un no terminal'
      puts '- - - - - - - - - - - -'
      no_terminal = gets.chomp
      @no_terminales << no_terminal
      @tabla[no_terminal] = {}
      puts 'Algo mas?..'
      puts '0) NO'
      puts '1) SI'
        algo_mas = gets.chomp
      algo_mas == '1' ? algo_mas= true : algo_mas= false
    end
  end

  def leer_simbolos_de_entrada
    puts "\n\n## Ingrese los simbolos de entrada ##"
    puts "_________________________________________"
    algo_mas = true
    while algo_mas
      #pedir simbolos de entrada
      puts 'Ingrese un simbolo'
      puts '- - - - - - - - - '
      simbolo = gets.chomp
      @simbolos_de_entrada << simbolo
      puts 'Algo mas?..'
      puts '0) NO'
      puts '1) SI'
      algo_mas = gets.chomp
      algo_mas == '1' ? algo_mas= true : algo_mas= false
    end
    @simbolos_de_entrada << '$'
  end

  def cargar_tabla()
    @no_terminales.each do |nt|
      @simbolos_de_entrada.each do |se|
        otra_produccion = true
        @tabla[nt][se] = []
        while otra_produccion
          puts "Ingrese una produccion para M[#{nt}][#{se}]."
          puts "Si M[#{nt}][#{se}] no tiene produccion, presione ENTER"
          produccion = gets.chomp.strip
          produccion.length < 1 ? @tabla[nt][se] = nil : @tabla[nt][se]<<produccion
          puts 'Algo mas?..'
          puts '0) NO'
          puts '1) SI'
          otra_produccion = gets.chomp
          otra_produccion == '1' ? otra_produccion= true : otra_produccion= false
        end
      end
    end
  end

  def imprimir_tabla
    row = ''
    (['---']+@simbolos_de_entrada).each{ |nt| row+="---#{nt}---|" }
    puts row
    sub_r = '_'
    row.length.times {sub_r+='='}
    puts sub_r
    sep = '|'
    @no_terminales.each do |nt|
      row = ''
      @simbolos_de_entrada.each do |se|
        row+= "---#{@tabla[nt][se] ? @tabla[nt][se] : " "}---#{sep}"
      end
      puts "---#{nt}---#{sep}"+row
      sub_r = '_'
      row.length.times {sub_r+='_'}
      puts sub_r
      puts "\n"
    end
  end

  def ask_user
    leer_no_terminales
    leer_simbolos_de_entrada
    cargar_tabla
  end


  def leer_entrada
    puts "## Introduzca la cadena de entrada ##"
    puts "Obs: cada simbolo debe estar seguido de un espacio"
    puts "   El simbolo % representa al vacio"
    puts "   Los terminales 'prima', se representan por la minuscula de su letra. Ej: para T' es t"
    @entrada = @testing_entrada || gets.chomp.strip
    @entrada = @entrada.split(/[\sw]/)
    puts @entrada.inspect
    verificar_entrada
    procesar if @errores.length == 0
  end

  def verificar_entrada
    @entrada_nickname = []
    @entrada.each{|e| @entrada_nickname << translate_to_nickname(e)}
    puts "Entrada : #{@entrada.inspect}"
    puts "Entrada nickname: #{@entrada_nickname.inspect}" if @show_translating

    @testing = testing
    #using nicknames
    @entrada = @entrada_nickname
    @simbolos_de_entrada = @simbolos_de_entrada_nicknames
    #------------------------------------------------
    @entrada.each do |token|
      unless @simbolos_de_entrada.include? token
        @errores << "el simbolo #{token} no pertenece a los simbolos de entrada"
      end
      puts @errores if @errores.length > 0
    end
  end #verificar_entrada

  def avanzar_entrada
    @ip+=1
    puts "\n+++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "Avanzando entrada:"
    puts "IP ahora es #{@ip}, apunta a #{@nicknames[@entrada[@ip]]}"
    puts "==================================================="
  end

  def sacar_de_la_pila
    # sacar de la pila y avanzar ip
    puts "\n+++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "Pila Actual: #{translate_array(@pila)}" if @testing
    puts "Sacando de la pila el elemento: #{@nicknames[@pila.pop]}"
    puts "Pila despues: #{translate_array(@pila)}"  if @testing
    puts "==================================================="
  end

  def sacar_y_avanzar
    sacar_de_la_pila
    avanzar_entrada
  end

  def error_x_es_un_terminal
    #error()
    puts "You got Error 1!"
  end

  def error_no_existe_entrada
    #se utiliza * como sync
    puts "\n+++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "You got Error 2!"
    puts '---------------'
    puts "Tabla[#{@nicknames[@x]},#{@nicknames[@entrada[@ip]]}] es indefinido."
    puts "Insertando caracter sync (~) en Tabla[#{@nicknames[@x]},#{@nicknames[@entrada[@ip]]}]."
    @tabla[@x][@entrada[@ip]] = '~' #insertar caracter de sincronizacion
    puts "Dejando el tope de la pila como esta."
    puts "Pila: #{translate_array(@pila).inspect}"
    puts "==================================================="
    avanzar_entrada
  end

  def cargar_produccion_invertida
    puts "\n+++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts 'Cargando produccion invertida'
    puts '-----------------------------'
    puts "Produccion: #{@tabla_original[@nicknames[@x]][@nicknames[@entrada[@ip]]]}"
    @pila = @pila+invertir(@tabla[@x][@entrada[@ip]])
    puts "Pila despues con nuevos elementos: #{translate_array(@pila)}"  if (@testing or @show_translating)
    puts "==================================================="
  end

  def pause?
    if @testing
      puts "Presione una tecla para iterar..."
      gets
    end
  end

  def show_output
    #Enviar a la salida la produccion
    puts "\n+++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "Produccion: #{@nicknames[@x]} => #{@tabla_original[@nicknames[@x]][@nicknames[@entrada[@ip]]]}"
    puts "==================================================="
  end

  def inicializar_var_procesar
    #using nicknames
    @no_terminales = @no_terminales_nicknames
    @fin_cadena = @nicknames.key('$')
    #------------------------------------------------
    @entrada << @fin_cadena
    @ip = 0
    @pila = [@fin_cadena]<< @no_terminales[0]
    @x = @pila.last
  end #inicializar_var_procesar

  def translate_array(a)
    puts "Traslating: #{a.inspect}" if @show_translating
    p=[]
    a.each{|v| p << @nicknames[v]}
    p
  end
  # ejecuta el algoritmo Asp
  def procesar
    #using nicknames
    @tabla_original = @tabla
    @tabla = @tabla_nicknames
    @entrada = @entrada_nickname
    #------------------------------------------------
    nro_proceso = 0
    puts 'PROCESANDO'
    puts '---------'
    inicializar_var_procesar
    while (@x != @nicknames.key('$')) do
      nro_proceso += 1
      puts "\n\n\n+++++++++++++++++++++++++++++++++++++++++++++++++++"
      puts "(#{nro_proceso}) - Datos a procesar:"
      puts '----------------------'
      p = translate_array(@pila)
      puts "Pila: #{p.inspect} "
      p = translate_array(@entrada)
      puts "Entrada: #{p}"
      puts "IP: #{@ip}"
      puts "Token: #{@nicknames[@entrada[@ip]]}"
      puts "Item de la pila (X): #{@nicknames[@x]}"
      puts "==================================================="

      if @x == @entrada[@ip]
        sacar_y_avanzar
      elsif simbolos_de_entrada.include? @x
        error_x_es_un_terminal
      elsif @tabla[@x][@entrada[@ip]].nil?
        error_no_existe_entrada
      elsif !@tabla[@x][@entrada[@ip]].nil?
        show_output
        sacar_de_la_pila
        cargar_produccion_invertida
      end
      @x = @pila.last
      pause?
    end
    puts "\n\n\n============================"
    puts "| Producciones Realizadas: #{translate_array(@producciones_realizadas).join('=>')}"
    puts "============================"
      #imprimir_tabla
  end #procesar

  def invertir(produccion)

      produccion = if produccion == '%'
        puts ">>> La produccion es vacia (%) <<<"
        []
      else
        produccion.reverse.split ''
      end

      puts "Produccion invertida: #{translate_array(produccion)}"
      @producciones_realizadas += produccion
      produccion
  end

  def iniciar
    @errores = []
    @testing ? load_testing_data : ask_user
    imprimir_tabla

    load_testing_simbolos_de_entrada

    load_nicknames
    load_no_terminales_nicknames
    load_simbolos_de_entrada_nicknames
    load_tabla_nicknames
    imprimir_tabla_nicknames if @show_translating
    leer_entrada

  end

end
