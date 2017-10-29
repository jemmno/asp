# /bin/irb.rb
# load 'asp.rb'
# asp = Asp.new(true, 'id + id')
# asp.iniciar
# O load 'asp.rb'; asp = Asp.new(true, '+ i + i'); asp.iniciar
# el simbolo % representa al vacio
class Asp
  attr_accessor :tabla
  attr_accessor :no_terminales
  attr_accessor :simbolos_de_entrada
  attr_accessor :testing

  def initialize(testing=false,testing_entrada=nil)
    @testing = testing
    @testing_entrada = testing_entrada
    @tabla = {}
    @no_terminales = []
    @simbolos_de_entrada = []
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
    @no_terminales.each do |nt|
      row = ''
      @simbolos_de_entrada.each do |se|
        row+= "#{@tabla[nt][se].inspect} "
      end
      puts row
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

  def load_testing_data
    load_testing_no_terminales
    load_testing_simbolos_de_entrada
    load_testing_tabla
  end

  def load_testing_no_terminales
    @no_terminales = ['E',"e","T","t","F"]
  end

  def load_testing_simbolos_de_entrada
    @simbolos_de_entrada = ['i','+','*','(',')','$']
  end

  def load_testing_tabla
    e = ["Te",nil,nil,"TE'",nil,nil]
    ee = [nil, "+Te",nil,nil,'%','%']
    t = ["Ft",nil,nil,"Ft",nil,nil]
    tt = [nil,'%', "*Ft",nil, '%','%']
    f = ['i',nil,nil,'(E)', nil,nil]

    producciones = e+ee+t+tt+f
    i = 0
    @no_terminales.each do |nt|
      @tabla[nt] = {}
      @simbolos_de_entrada.each do |se|
        @tabla[nt][se] = producciones[i]
        i+=1
      end
    end
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
    @entrada.each do |token|
      unless @simbolos_de_entrada.include? token
        @errores << "el simbolo #{token} no pertenece a los simbolos de entrada"
      end
      puts @errores if @errores.length > 0
    end
  end #verificar_entrada

  def inicializar_var_procesar
    @entrada << '$'
    @ip = 0
    @pila = ['$']<< no_terminales[0]
    @x = @pila.last
  end #inicializar_var_procesar

  def avanzar_entrada
    @ip+=1
    puts "\n+++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "Avanzando entrada:"
    puts "IP ahora es #{@ip}, apunta a #{@entrada[@ip]}"
    puts "==================================================="
  end

  def sacar_de_la_pila
    # sacar de la pila y avanzar ip
    puts "\n+++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "Pila Actual: #{@pila}" if @testing
    puts "Sacando de la pila el elemento: #{@pila.pop}"
    puts "Pila despues: #{@pila}"  if @testing
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
    puts "Tabla[#{@x},#{@entrada[@ip]}] es indefinido."
    puts "Insertando caracter sync (~) en Tabla[#{@x},#{@entrada[@ip]}]."
    @tabla[@x][@entrada[@ip]] = '~' #insertar caracter de sincronizacion
    puts "Dejando el tope de la pila como esta."
    puts "Pila: #{@pila.inspect}"
    puts "==================================================="
    avanzar_entrada
  end

  def cargar_produccion_invertida
    puts "\n+++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts 'Cargando produccion invertida'
    puts '-----------------------------'
    @pila = @pila+invertir(@tabla[@x][@entrada[@ip]])
    puts "Pila despues con nuevos elementos: #{@pila}"  if @testing
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
    puts "Produccion: #{@x} => #{@tabla[@x][@entrada[@ip]]}"
    puts "==================================================="
  end

  # ejecuta el algoritmo Asp
  def procesar
    nro_proceso = 0
    puts 'PROCESANDO'
    puts '---------'
    inicializar_var_procesar
    while (@x != '$') do
      nro_proceso += 1
      puts "\n\n\n+++++++++++++++++++++++++++++++++++++++++++++++++++"
      puts "(#{nro_proceso}) - Datos a procesar:"
      puts '----------------------'
      puts "Pila: #{@pila.inspect}"
      puts "Entrada: #{@entrada}"
      puts "IP: #{@ip}"
      puts "Token: #{@entrada[@ip]}"
      puts "Item de la pila (X): #{@x}"
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
    puts "| Producciones Realizadas: #{@producciones_realizadas.join('=>')}"
    puts "============================"
  end #procesar

  def invertir(produccion)
      puts "Produccion: #{produccion}"
      produccion = if produccion == '%'
        puts ">>> La produccion es vacia (%) <<<"
        []
      else
        produccion.reverse.split ''
      end

      puts "Produccion invertida: #{produccion}"
      @producciones_realizadas += produccion
      produccion
  end

  def iniciar
    @errores = []
    @testing ? load_testing_data : ask_user
    imprimir_tabla
    leer_entrada

  end

end
