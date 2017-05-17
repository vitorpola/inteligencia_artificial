# ler o arquivo e preencher em uma matriz 
def read_file(file_name)
    a =[]
    File.open(file_name) do |f|
        f.each_line.each do |line|
            a << line.split(',').map(&:to_i)
        end
    end
    return a
end


# retorna um array removendo a colunas indicadas
def remove_column(data, cols)
    num_cols = data.first.count

    data.each do |d|
        cols.each do |c|
            d.delete_at(c)
        end
    end
    
    return data
end


# retorna um array a partir de um outro passado por parametro
def fill_array(array, init, final)
    a = []
    for i in init..final
        a << array[i]
    end    
    return a
end

# normalizar utilizando min-max 
def normalize(arr, col)
    max = arr[0][col]
    min = arr[0][col]
    for i in 1..arr.count-1
        min = arr[i][col] if arr[i][col] < min 
        max = arr[i][col] if arr[i][col] > max
    end
    for i in 0..arr.count-1
        arr[i][col] = (arr[i][col]-min).to_f / (max-min).to_f
    end
    return arr
end

# converter resultados
def result_convert(num)
    if num == 1
        return [ 1,-1,-1]
    elsif num == 2
        return [-1, 1,-1]
    else
        return [-1,-1, 1]
    end
end

# inicializar o pesos
def init_weights(row, col)
    weights = []
    for i in 0..row-1
        weights << []
        for j in 0..col-1
            weights[i] <<  Random.rand(-0.5..0.5).round(4)
        end
    end
    weights
end

# inicializar o pesos Nguyen Windrow
def init_weights_nw(row, col)
    weights = []
    w_old = []
    beta = 0.7 * (row ** (1/col))
    for i in 0..row-1
        weights << []
        for j in 0..col-1
            weights[i] <<  Random.rand(-0.5..0.5).round(2)
        end
    end

    for i in 0..row-1
        w_old << 0
        for j in 0..col-1
            w_old[i] += weights[i][j] ** 2
        end
        w_old[i] = Math.sqrt(w_old.last)
    end

    for i in 1..row-1
        w_old
        for j in 0..col-1
            weights[i][j] = weights[i][j] * beta / w_old[i] 
        end
    end
    
    weights
end

def mlp(array_data, is_test, tmax, hn)
    x_count = array_data.first.count-1
    right_answers = 0 if is_test
    for t in 1..tmax
        if is_test
            line = t-1
        else
            line = Random.rand(0..999)
        end

        x = []
        for i in 0..x_count-1
            x << array_data[line][i]
        end
        x << 1
        se = result_convert(array_data[line].last)

        z = []
        for j in 0..hn-1
            z[j] = @v.last[j]
            for i in 0..x_count-1
                z[j] += x[i] * @v[i][j]
            end
            z[j] = 1.0/ (1+ Math.exp(-z[j]))
        end

        z << 1

        y = []
        sr = []
        for k in 0..2
            y[k] = @w[0][k] 
            for j in 1..hn
                y[k] += z[j] * @w[j][k]
            end
            y[k] = 1.0/ (1+ Math.exp(-y[k]))
            sr << (y[k] >= 0.50 ? 1 : -1)
        end

        if sr == [-1,-1,-1]
            min = y[0].abs
            min_index = 0
            for i in 1..2
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
            
            for k in 0..2
                dy << ( se[k] - sr[k] ) * y[k] * ( 1 - y[k] )
            end

            for j in 0..hn-1
                dz[j] = 0
                for k in 0..2
                    dz[j] += dy[k]*@w[j][k]
                end
                dz[j] *= z[j]*(1-z[j])
            end
            
            for i in 0..x_count
                for j in 0..hn-1
                    @v[i][j] += @alpha*x[i]*dz[j]
                end
            end

            for j in 0..hn-1
                for k in 0..2
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
all_data = remove_column(all_data, [0,0,0,0,0,0])

p all_data.first.inspect

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

@alpha = 0.45             # taxa 
tmax = 100
hnode = 2 # quantidade de nós na camada invisivel

sum = 0

@v = init_weights(input_count+1, hnode) # pesos mlp

puts @v.inspect

@w = init_weights(hnode+1,  3) # pesos mlp

puts @w.inspect

mlp(trainning, false, tmax, hnode)
res =  mlp(test, true, test.count, hnode)

p (100*res).round(2).to_s + '%'


