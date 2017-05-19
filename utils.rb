require 'nyaplot'

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

def choose_data(array, percent)
    c = [[],[],[]]
    r = [[],[]]
    
    array.each do |line|
        c[line.last-1] << line
    end

    for j in 0..2
        n = c[j].count
        for i in 0..n-1
            ind =  Random.rand(0..c[j].count-1)
            if(i.to_f/n < percent) 
                r[0] << c[j][ind]
            else
                r[1] << c[j][ind]            
            end
            c[j].delete_at(ind)
        end
    end
    r
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
        arr[i][col] = ((arr[i][col]-min).to_f / (max-min).to_f) -0.5
    end
    return arr
end

# converter resultados
def result_convert(num, xor = false)
    if xor
        return [num]
    elsif num == 1
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
            weights[i] << Random.rand(-0.5..0.5) 
        end
    end
    weights
end

# inicializar o pesos Nguyen Windrow
def nguyen_windrow(v)
    count_x = v.count - 1
    count_z = v.first.count
    v_old = []
    beta = 0.7 * (count_z ** ( 1.0 / count_x ))
    for j in 0..count_z - 1
        v_old << 0
        for i in 0..count_x - 1
            v_old[j] += v[i][j] ** 2
        end
        v_old[j] = Math.sqrt(v_old[j])
    end

    for i in 0..count_z -1 
        for j in 0..count_x 
            v[j][i] *= beta/v_old[i] if i != count_x
            v[j][i] = Random.rand(-beta..beta) if i == count_x
        end
    end
    v
end

# gerar grafico
def generate_chart(lines, columns)
    plot2 = Nyaplot::Plot.new
    
    sc1 = plot2.add(:scatter, lines[0], columns[0])
    sc1.color('#f00')
    sc1.title('Classe 1')

    sc2 = plot2.add(:scatter, lines[1], columns[2])
    sc2.color('#0f0')
    sc2.title('Classe 2')

    sc3 = plot2.add(:scatter, lines[2], columns[2])
    sc3.color('#00f')
    sc3.title('Classe 3')

    plot2.legend(true)
    plot2.export_html("result/kohonen.html")
end
