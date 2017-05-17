load 'utils.rb' 

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

#todos dados
all_data = read_file('cmc.data.txt')

# normarlizar os dados
for i in 0..8
    all_data = normalize(all_data, i)
    #puts all_data[0].inspect
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

@alpha = 0.4             # taxa 
tmax = 10000

@weights = init_weights(3,10, false) # pesos perceptron

perceptron(trainning, false, tmax)
perceptron(test, true, test.count)
