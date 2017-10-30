module ModuleTdata
    def load_testing_data
      load_testing_no_terminales
      load_testing_simbolos_de_entrada
      load_testing_tabla
    end

    def load_testing_no_terminales
      @no_terminales = ['E',"E'","T","T'","F"]
    end

    def load_testing_simbolos_de_entrada
      @simbolos_de_entrada = ['id','+','*','(',')','$']
    end

      def load_testing_tabla
        e = ["TE'",nil,nil,"TE'",nil,nil]
        ee = [nil, "+TE'",nil,nil,'%','%']
        t = ["FT'",nil,nil,"FT'",nil,nil]
        tt = [nil,'%', "*FT'",nil, '%', '%']
        f = ['id',nil,nil,'(E)',nil, nil]

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
end
