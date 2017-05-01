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
def init_weights(row, col, random)
    weights = []
    for i in 0..row-1
        weights << []
        for j in 0..col-1
            weights[i] << (random  ? Random.rand(-1.0..1.0) : 0)
        end
    end
    weights
end

def perceptron(array_data, is_test, tmax)
    x_count = 9
    y_count = 3

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
        for i in 0..x_count-1 
            x << array_data[line][i]
        end
        x << 1
        se = result_convert(array_data[line][x_count])

        y_in = [0,0,0]

        for i in 0..y_count-1
            for j in 0..x_count
                y_in[i] += x[j] * @weights[i][j]
            end
        end

        y = []
        y_in.each { |i| y << (i >= 0 ? 1 : -1) }

        if y == [-1,-1,-1]
            min = y_in[0].abs
            min_index = 0
            for i in 1..y_count-1
                if y_in[i].abs < min
                    min = y_in[i].abs
                    min_index = i
                end
            end
            y[min_index] = 1
        end

        if y != se && !is_test
            for i in 0..y_count-1
                for j in 0..x_count-1
                     @weights[i][j] += @alpha * ( se[i] - y[i] ) * x[j] 
                end   
            end
        end

        right_answers += 1 if y == se && is_test
    end
    puts "Perceptron \t-> #{ 100* right_answers /tmax }%" if is_test
end

def mlp(array_data, is_test, tmax, hl)
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
        for i in 0..8 
            x << array_data[line][i]
        end
        x << 1
        se = result_convert(array_data[line][9])

        z = []
        for j in 0..hl-1
            z[j] = @v[j][hl-1] 
            for i in 0..9
                z[j] += x[i] * @v[i][j]
            end
            z[j] = 1.0/ (1+ Math.exp(-z[j]))
        end

        y = []
        sr = []
        for k in 0..2
            y[k] = @w[hl-1][k] 
            for j in 0..hl-1
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

            for j in 0..hl-1
                dz[j] = 0
                for k in 0..2
                    dz[j] += dy[k]*@w[j][k]
                end
                dz[j] *= z[j]*(1-z[j])
            end
            
            for i in 0..9
                for j in 0..hl-1
                    @v[i][j] += @alpha*x[i]*dz[j]
                end
            end

            for j in 0..hl-1
                for k in 0..2
                    @w[j][k] += @alpha*z[j]*dy[k]
                end
            end
        end
        
        right_answers += 1 if se == sr && is_test
    end
    puts "MLP \t\t-> #{ 100* right_answers /tmax }%" if is_test
end

#todos dados
all_data = read_file('cmc.data.txt')

# normarlizar os dados
for i in 0..8
    #all_data = normalize(all_data, i)
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

@alpha = 0.1             # taxa 
tmax = 10000
qty_hl = 3 # quantidade de camada invisivel

@weights = init_weights(3,10, false) # pesos perceptron
@v = init_weights(10, qty_hl, true) # pesos mlp
@w = init_weights(qty_hl+1,  3, true) # pesos mlp


perceptron(trainning, false, tmax)
perceptron(test, true, test.count)
mlp(trainning, false, tmax, qty_hl)
mlp(test, true, test.count, qty_hl)