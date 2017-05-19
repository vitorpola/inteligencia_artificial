load 'utils.rb' 

def mlp(array_data, is_test, tmax)
    right_answers = 0 if is_test
    for t in 1..tmax
        z = []
        y = []
        sr = []
        x = []

        if is_test
            line = t-1
        else
            c1 = 43*array_data.count/100
            c2 = 23*array_data.count/100
            if t%3 == 1
                line = Random.rand(0..c1-1)
            elsif t%3 == 2
                line = Random.rand(c1..c1+c2)
            else
                line = Random.rand(c1+c2..array_data.count-1)
            end
        end

        for i in 0..@N_x-1
            x << array_data[line][i]
        end
        x << 1
        #se = [array_data[line].last == 1 ? 1 : -1]   # para uma classe
        se = result_convert(array_data[line].last)

        # propaga de x para z
        for j in 0..@N_z-1
            z_in = 0
            for i in 0..@N_x
                z_in += x[i] * @v[i][j]
            end
            z << 1.0 / (1+ Math.exp( -z_in ))
        end
        z << 1

        # propaga de z para y
        for k in 0..@N_y-1
            y_in = 0
            for j in 0..@N_z
                y_in += z[j] * @w[j][k]
            end
            y << 1.0 / ( 1 + Math.exp( -y_in ))
            sr << (y[k] >= 0.5 ? 1 : -1)
        end

        # ajuste 
        if sr == [-1,-1,-1]
            min = y[0].abs
            min_index = 0
            for i in 1..@N_y-1
                if y[i].abs < min
                    min = y[i].abs
                    min_index = i
                end
            end
            sr[min_index] = 1
        end

        # se errou, backpropagation
        if se != sr && !is_test
            dy = []
            dz = []
            
            # calcular delta y            
            for k in 0..@N_y-1
                dy << ( se[k] - sr[k] ) * y[k] * ( 1 - y[k] )
            end
            
            # calcular delta z
            for j in 0..@N_z
                sum = 0
                for k in 0..@N_y-1
                    sum += dy[k]*@w[j][k]
                end
                dz[j] = sum * z[j] * ( 1 - z[j] )
            end

            #atualiza pesos W
            for j in 0..@N_z
                for k in 0..@N_y-1
                    @w[j][k] += @alpha*z[j]*dy[k]
                end
            end
            
            #atualiza pesos V
            for i in 0..@N_x
                for j in 0..@N_z-1
                    @v[i][j] += @alpha*x[i]*dz[j]
                end
            end
        end
        
        right_answers += 1 if se == sr && is_test
    end
    return right_answers /tmax.to_f if is_test
end

#todos dados
all_data = read_file('data/cmc.data.txt')
#all_data = read_file('data/xor.txt')

#remover feature
all_data = remove_column(all_data, [6])

@N_x = all_data.first.count-1 # número de features (entradas X)
@N_z = 9 # número de nós ocultos (camada Z)
@N_y = 3 # número de classe (camada Y)

# normarlizar os dados
(0..@N_x-1).each do |feature|
    all_data = normalize(all_data, feature)
end

selected_data = choose_data(all_data, 0.55)
# dados treino
trainning = selected_data[0]
# dados teste
test = selected_data[1]

tmax = 20000
@alpha = 0.7           # taxa 

#  inicializar pesos
@v = init_weights( @N_x + 1, @N_z )
@v = nguyen_windrow( @v )
@w = init_weights( @N_z + 1, @N_y )

mlp(trainning, false, tmax)
res=mlp(test, true, test.count)

#mlp(all_data, false, tmax)
#res=mlp(all_data, true, all_data.count)

p (100*res).to_s + '%' 
 