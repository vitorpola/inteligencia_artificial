# ler o arquivo e preencher em uma matriz 
def read_file(file_name)
    a =[]
    File.open(file_name) do |f|
        f.lines.each do |line|
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

#todos dados
all_data = read_file('cmc.data.txt')

#dados treino com classe 1
trainning_1 = fill_array(all_data, 0, 414)
#dados treino com classe 2
trainning_2 = fill_array(all_data, 415, 641)
#dados treino com classe 3
trainning_3 = fill_array(all_data, 642, 999)

#dados teste com todas classes
test = fill_array(all_data, 1000, all_data.count-1)
