load 'utils.rb' 

def mlp(array_data, is_test, tmax, hn)
    x_N = array_data.first.count-1 
    z_N = hn
    y_N = 3

    right_answers = 0 if is_test
    for t in 1..tmax
        if is_test
            line = t-1
        else
            if t%3 == 1
                line = Random.rand(0..414)
            elsif t%3 == 2
                line = Random.rand(415..641)
            else
                line = Random.rand(642..999)
            end
        end

        x = []
        for i in 0..x_N-1
            x << array_data[line][i]
        end
        x << 1
        se = result_convert(array_data[line].last)

        z = []
        for j in 0..z_N-1
            z[j] = @v.last[j]
            for i in 0..x_N-1
                z[j] += x[i] * @v[i][j]
            end
            z[j] = 1.0/ (1+ Math.exp(-z[j]))
        end

        z << 1

        y = []
        sr = []
        for k in 0..y_N-1
            y[k] = @w.last[k] 
            for j in 0..z_N-1
                y[k] += z[j] * @w[j][k]
            end
            y[k] = 1.0/ (1+ Math.exp(-y[k]))
            sr << (y[k] >= 0.50 ? 1 : -1)
        end

        if sr == [-1,-1,-1]
            min = y[0].abs
            min_index = 0
            for i in 1..y_N-1
                if y[i].abs < min
                    min = y[i].abs
                    min_index = i
                end
            end
            y[min_index] = 1
        end

        if se != sr && !is_test
            dy = []
            dz = []
            
            for k in 0..y_N-1
                dy << ( se[k] - sr[k] ) * y[k] * ( 1 - y[k] )
            end

            for j in 0..z_N
                dz[j] = 0
                for k in 0..y_N-1
                    dz[j] += dy[k]*@w[j][k]
                end
                dz[j] *= z[j]*(1-z[j])
            end
            
            for i in 0..x_N
                for j in 0..z_N-1
                    @v[i][j] += @alpha*x[i]*dz[j]
                end
            end

            for j in 0..z_N
                for k in 0..y_N-1
                    @w[j][k] += @alpha*z[j]*dy[k]
                end
            end
        end
        
        right_answers += 1 if se == sr && is_test
    end
    return right_answers /tmax.to_f if is_test
end

#todos dados
all_data = read_file('cmc.data.txt')
all_data = remove_column(all_data, [0])

input_count = all_data.first.count - 1

# normarlizar os dados
(0..all_data.first.count-2).each do |line|
    all_data = normalize(all_data, line)
end

# dados treino
#      classe 1: 0   - 414
#      classe 2: 415 - 641
#      classe 3: 642 - 999
trainning = fill_array(all_data, 0, 999)

# dados teste
#      classe 1: 1000- 1213
#      classe 2: 1214 - 1319
#      classe 3: 1320 - 1472
test = fill_array(all_data, 1000, all_data.count-1)

@alpha = 0.8             # taxa 
tmax = 1000
hnode = 5 # quantidade de nós na camada invisivel

@v = init_weights(input_count+1, hnode) # pesos mlp
@w = init_weights(hnode+1,  3) # pesos mlp

mlp(trainning, false, tmax, hnode)
res =  mlp(test, true, test.count, hnode)

p (100*res).to_s + '%'


