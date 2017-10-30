module ModuleNickname

  def load_no_terminales_nicknames
    @no_terminales_nicknames = []
    @no_terminales.each{|nt| @no_terminales_nicknames << @nicknames.key(nt)}
    puts "\nno_terminales_nicknames => #{@no_terminales_nicknames.inspect}"  if @show_translating
  end



  def load_simbolos_de_entrada_nicknames
    @simbolos_de_entrada_nicknames = []
    @simbolos_de_entrada.each{|se| @simbolos_de_entrada_nicknames << @nicknames.key(se)}
    @simbolos_de_entrada.each{|se| @simbolos_de_entrada_nicknames << @nicknames.key(se)}
    puts "\nsimbolos_de_entrada_nicknames => #{@simbolos_de_entrada_nicknames.inspect}" if @show_translating
  end

  def translate_to_nickname(produccion)
    translated = produccion
    if translated
      sv = @nicknames.values.sort_by(&:length).reverse
      sv.each{|v| translated = translated.gsub(v,@nicknames.key(v))}
    end
    translated
  end

  def load_tabla_nicknames
    @tabla_nicknames = {}

    i = 0
    @no_terminales.each do |nt|
      @tabla_nicknames[@nicknames.key(nt)] = {}
      @tabla_nicknames[@nicknames.key(nt)] = {}
      @simbolos_de_entrada.each do |se|
        @tabla_nicknames[@nicknames.key(nt)][@nicknames.key(se)] = translate_to_nickname(@tabla[nt][se])
        i+=1
      end
    end

  end

  def imprimir_tabla_nicknames
    @no_terminales_nicknames.each do |nt|
      row = ''
      @simbolos_de_entrada_nicknames.each do |se|
        row+= "#{@tabla_nicknames[nt][se].inspect} "
      end
      puts row
      sub_r = '_'
      row.length.times {sub_r+='_'}
      puts sub_r
      puts "\n"
    end
  end

  def load_nicknames
    puts "\n+++++++++++++++++++++++++++++++++++++++++++++++++++"
    (@simbolos_de_entrada+@no_terminales).each_with_index{|e,i| @nicknames[(i+65).chr] = e}
    if @show_translating
      puts "Filling up nicknames"
      puts "--------------------"
      puts "nicknames => #{@nicknames.inspect}"
    end
    puts "==================================================="
  end

end
