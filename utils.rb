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
def init_weights(row, col, random = true)
    weights = []
    for i in 0..row-1
        weights << []
        for j in 0..col-1
            weights[i] <<  (random  ? Random.rand(-0.5..0.5).round(4) : 0) 
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

# gerar grafico
def generate_chart
    sc_y=[]; sc_x=[]; a=0.5; b=3; noise=1.5; x=0
    rnd = Random.new
    while x<10
    sc_x.push(x)
    sc_y.push(a*x+b+noise*(rnd.rand-0.5))
    x=(x+0.5).round(1)
    end
    plot2 = Nyaplot::Plot.new
    sc = plot2.add(:scatter, sc_x, sc_y)
    sc.color('#000')
    sc.title('point')
    plot2.legend(true)
    plot2.export_html("result/scatter_line.html")
end
