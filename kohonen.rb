load 'utils.rb' 

def get_distance(x, row, col)
    d = 0
    for i in 0..@N_x-1 
        d += (x[i]-@w[i][row][col])**2
    end
    Math.sqrt(d)
end

def sigma(t)
    (@N_matrix / 2) * Math.exp( -( t.to_f / (@tmax / Math.log( @N_matrix / 2 )).to_f ) )
end

def learning_rate(t)
    @learn_rate * Math.exp( -( t.to_f / @tmax.to_f ) )
end

def alpha(dist, t)
    Math.exp(-(dist ** 2 ).to_f / (2 * sigma(t) ** 2 ).to_f)
end

def init_weights
    w = []
    for i in 0..@N_x-1
        w << []
        for j in 0..@N_matrix-1
            w[i] << []
            for k in 0..@N_matrix-1
                w[i][j][k] = Random.rand(0..1.0)    
            end
        end
    end
    w
end

def get_influence(t, d)
    alpha(Math.sqrt(d.to_f), t.to_f) * learning_rate(t)
end

def kohonen(array_data, is_test)

    lines = [[],[],[]] if is_test
    columns = [[],[],[]] if is_test

    @tmax = array_data.count if is_test
    for t in 1..@tmax
        if is_test
            line = t-1
        else
            line = Random.rand(0..array_data.count-1)
        end
        x = array_data[line]
        min_distance = 999999
        winner_row = -1
        winner_col = -1
        
        for row in 0..@N_matrix-1
            for col in 0..@N_matrix-1
                d_temp = get_distance(x, row, col)
                if d_temp < min_distance
                    min_distance = d_temp
                    winner_row = row
                    winner_col = col
                end
            end
        end

        if is_test
            lines[x.last-1] <<  winner_row
            columns[x.last-1] <<  winner_col
        else
            for row in 0..@N_matrix-1
                for col in 0..@N_matrix-1
                    d = (winner_row - row) ** 2 + (winner_col - col) ** 2
                    if d < sigma(t) ** 2
                        influence = get_influence(t, d).to_f
                        for k in 0..@N_x-1
                            @w[k][row][col] += influence * (x[k] - @w[k][row][col])
                        end
                    end
                end
            end
        end
        system "clear"
        system "cls"
        puts "#{(t*100.0/@tmax).round(2)}%" 
    end
    puts 'Grafico gerado em result/kohonen.html'
    {lines: lines, columns: columns} if is_test
end
    
#todos dados
all_data = read_file('data/cmc.data.txt')

@N_x = 9
@N_matrix = 10
@tmax = 100
@learn_rate = 0.1

selected_data = choose_data(all_data, 0.8)
# dados treino
trainning = selected_data[0]
# dados teste
test = selected_data[1]

@w = init_weights

kohonen(trainning, false)
result = kohonen(test, true)

generate_chart(result[:lines], result[:columns])

