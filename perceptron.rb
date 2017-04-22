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

# inicializar o pesos com zero
def init_weights
    weights = []
    for i in 0..2 
        weights << []
        for j in 0..8
            weights[i] << 0
        end
    end
    weights
end

#todos dados
all_data = read_file('cmc.data.txt')

# normarlizar os dados do primeiro atributo
all_data = normalize(all_data, 0)

# dados treino
#      classe 1: 0   - 414
#      classe 2: 415 - 641
#      classe 3: 642 - 999
trainning = fill_array(all_data, 0, 999)

# dados teste com todas classes
test = fill_array(all_data, 1000, all_data.count-1)

@weights = init_weights     # pesos
@alpha = 0.4                # somatorio das entradas * pesos
@right_answers = 0;

def perceptron(array_data, is_test, tmax)
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

        y_in = [0,0,0]
        
        for i in 0..2 
            for j in 0..8
                y_in[i] += x[j] * @weights[i][j]
            end
        end

        y = []
        y_in.each { |i| y << (i >= 0 ? 1 : -1) }

        if y == [-1,-1,-1]
            min = y_in[0].abs
            min_index = 0
            for i in 1..2
                if y_in[i].abs < min
                    min = y_in[i].abs
                    min_index = i
                end
            end
            y[min_index] = 1
        end

        if y != se && !is_test
            for i in 0..2
                for j in 0..8
                     @weights[i][j] += @alpha * ( se[i] - y[i] ) * x[j] 
                end   
            end
        end

        @right_answers += 1 if y == se && is_test
    end
    puts "Porcentagem de acerto -> #{ 100* @right_answers /tmax }%" if is_test
end

perceptron(trainning, false, 5000)
perceptron(test, true, test.count)