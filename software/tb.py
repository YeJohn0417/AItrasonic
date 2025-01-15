import os
import numpy as np
import tensorflow as tf
from keras.models import load_model
from keras.layers import Conv2D, MaxPooling2D, GlobalAveragePooling2D, Dense

# 假設 .hex 檔案中的資料是以十六進位表示的整數
# def read_hex_file(file_path):
#     with open(file_path, 'r') as file:
#         hex_data = file.read().split()
#     int_data = [int(h, 16) for h in hex_data]
#     return np.array(int_data, dtype=np.float32)

def read_hex_file(file_path):
    with open(file_path, 'r') as file:
        hex_data = file.read().split()
    # Convert hex to signed 8-bit integers using two's complement
    int_data = [(int(h, 16) if int(h, 16) < 128 else int(h, 16) - 256) for h in hex_data]
    # Write the int_data to a file in a specified folder
    output_folder = 'input_hex_data'
    os.makedirs(output_folder, exist_ok=True)
    output_file = os.path.join(output_folder, os.path.basename(file_path))
    with open(output_file, 'w') as f:
        f.write('\n'.join(str(x) for x in int_data))
    return np.array(int_data, dtype=np.float32)

def decompose_scale(scale):
    # 找到最接近的 2^n * integer 表示
    power = np.floor(np.log2(scale))
    base_2 = 2.0 ** power
    # integer_part = round(scale / base_2)
    integer_part = np.floor(scale / base_2)
    return integer_part, power

def quantize(data, layer, min_val=0, max_val=127):
    data_min = np.min(data)
    data_max = np.max(data)
    # print(f"Layer {layer} data_min:", data_min)
    # print("Values less than 0:", data[data < 0])

    # 計算原始 scale
    if (data_max - data_min != 0):
        raw_scale = (max_val - min_val) / (data_max - data_min)
    else:
        raw_scale = 1.0
    
    # 分解成整數乘以2的次方
    integer_part, power = decompose_scale(raw_scale)
    scale = integer_part * (2.0 ** power)
    
    # 使用新的 scale 進行量化
    quantized_data = min_val + (data - data_min) * scale
    # quantized_data = np.clip(quantized_data, min_val, max_val)
    
    if layer == 10:  # 避免最後一層的量化
        # quantized_data = data
        print(data)
        print(quantized_data)

    if layer == 8:  
        quantized_data = data
        print(data)
        print(quantized_data)

    # Use a global variable to track if this is the first call
    if not hasattr(quantize, 'first_call'):
        quantize.first_call = True
        # Clear file on first call
        with open('quant_params.txt', 'w') as f:
            f.write('')

    # Append data for each layer
    with open('quant_params.txt', 'a') as f:
        f.write(f'Layer {layer}:\n')
        f.write(f'data_min: {data_min}\n')
        f.write(f'data_max: {data_max}\n')
        f.write(f'raw_scale: {raw_scale}\n')
        f.write(f'decomposed_scale: {integer_part} * 2^{power}\n')
        f.write(f'final_scale: {scale}\n')
        f.write('-' * 30 + '\n')
    
    return np.round(quantized_data).astype(np.int8)
    # return np.round(quantized_data).astype(np.float32)

# 將數據寫入 .hex 檔案
# def write_hex_file(file_path, data):
#     with open(file_path, 'w') as file:
#         hex_data = [format(x, '02x') for x in data.flatten()]
#         file.write('\n'.join(hex_data))
def to_2s_complement(value):
        # 確保值在-128到127的範圍內
        value = int(value) % 256
        # 如果值大於127，則轉換為負數
        if value > 127:
            value -= 256
        return format(value & 0xFF, '02x')  # 轉換為16進位並保持2位數

def write_hex_file(file_path, data):
    # 獲取data的形狀
    data_shape = data.shape
    print(f"資料形狀: {data_shape}")
    with open(file_path, 'w') as file:
        # hex_data = [format((x + (1 << 8)) % (1 << 8), '02x') for x in data.flatten()]
        if len(data_shape) == 4:  # For convolutional layers
            hex_data = [to_2s_complement(x) for x in data.flatten()]
            flatten_data = []
            for c in range(data.shape[3]):  # channel
                for w in range(data.shape[2]):  # width
                    for h in range(data.shape[1]):  # height
                        for n in range(data.shape[0]):  # batch
                            flatten_data.append(data[n,h,w,c])
            hex_data = [to_2s_complement(x) for x in flatten_data]
            file.write('\n'.join(hex_data))
        elif len(data_shape) == 2:  # For dense layers
            hex_data = [to_2s_complement(x) for x in data.flatten()]
            flatten_data = []
            for c in range(data.shape[1]):  # channel
                for n in range(data.shape[0]):  # input
                    flatten_data.append(data[n,c])
            hex_data = [to_2s_complement(x) for x in flatten_data]
            file.write('\n'.join(hex_data))
        else:   
            hex_data = [format((x + (1 << 8)) % (1 << 8), '02x') for x in data.flatten()]

# 載入模型
original_model = load_model('model.h5')
model = tf.keras.models.clone_model(original_model)
model.set_weights(original_model.get_weights())
# 然後修改特定層的激活函數
for layer in model.layers:
    if isinstance(layer, Dense):
        layer.activation = tf.keras.activations.relu  # 或其他激活函數
model.summary()

# 讀取每一層的權重和偏差檔案
for i, layer in enumerate(model.layers):
    if isinstance(layer, (Conv2D, Dense)):
        weight_file = f'./model_parameters_quantized_hex/layer_{i}_weights_quantized.hex'
        bias_file = f'./model_parameters_quantized_hex/layer_{i}_biases_quantized.hex'
        
        weights_hex = read_hex_file(weight_file)
        biases_hex = read_hex_file(bias_file)
        
        weight_shape = layer.get_weights()[0].shape
        bias_shape = layer.get_weights()[1].shape
        
        weights = weights_hex.reshape(weight_shape)
        biases = biases_hex.reshape(bias_shape)
        
        layer.set_weights([weights, biases])

# 定義一個函數來進行運算
def compute_layer_output(layer, input_data):
    print(f'Computing output for layer: {layer.name}')
    print(f"Layer input negative values:", input_data[input_data < 0])
    output = layer(input_data)
    # if isinstance(layer, Conv2D):
    #     # print(f"Layer activation: {layer.activation.__name__}") 
    #     output = layer(input_data)
    # elif isinstance(layer, MaxPooling2D):
    #     output = layer(input_data)
    # elif isinstance(layer, GlobalAveragePooling2D):
    #     output = layer(input_data)
    #     # print("GlobalAveragePooling2D output:", output.numpy())
    #     # print("GlobalAveragePooling2D output:", output)
    # elif isinstance(layer, Dense):
    #     # print(f"Layer activation: {layer.activation.__name__}")
    #     output = layer(input_data)
    #     # if layer.activation.__name__ == 'relu':
    #     #     output = layer(input_data)
    #     # elif layer.activation.__name__ == 'softmax':
    #     #     layer.activation.__name__ = 'relu'
    #     #     output = layer(input_data)
    # else:
    #     output = input_data
    print(f"Layer output negative values:", output[output < 0])
    return output

# 讀取輸入數據的 .hex 檔案
# input_data_hex = read_hex_file('./all_data/test_resized_hex/A2C_hex/167s1_5.hex')
# input_data_hex = read_hex_file('./all_data/test_resized_hex/A2C_hex/6121s2_16.hex')
# input_data_hex = read_hex_file('./all_data/test_resized_hex/A2C_hex/130s1_1.hex')
# input_data_hex = read_hex_file('./all_data/test_resized_hex/A4C_hex/839s1_6.hex')
# input_data_hex = read_hex_file('./all_data/test_resized_hex/Other_hex/3521s1_33.hex') #now
# input_data_hex = read_hex_file('./all_data/test_resized_hex/PLAX_hex/5920s1_6.hex')
# input_data_hex = read_hex_file('./all_data/test_resized_hex/PLAX_hex/5920s1_10.hex')
# input_data_hex = read_hex_file('./all_data/test_resized_hex/PLAX_hex/5s1_8.hex')
input_data_hex = read_hex_file('./all_data/test_resized_hex/PLAX_hex/6180s1_21.hex') #ver1
# input_data_hex = read_hex_file('./all_data/test_resized_hex/PLAX_hex/6080s2_38.hex')
# input_data_hex = read_hex_file('./all_data/test_resized_hex/PSAX_hex/9s1_0.hex')
# input_data_hex = read_hex_file('./all_data/test_resized_hex/PSAX_hex/6121s1_22.hex')
input_data = input_data_hex.reshape((1, 100, 100, 1))  # 根據實際情況調整輸入數據的形狀
# input_data = input_data_hex  # 根據實際情況調整輸入數據的形狀

# 確保輸出資料夾存在
output_folder = 'output_folder'
os.makedirs(output_folder, exist_ok=True)
output_folder_not_quantized = 'output_folder_not_quantized'
os.makedirs(output_folder_not_quantized, exist_ok=True)
output_folder_not_quantized_hex = 'output_folder_not_quantized_hex'
os.makedirs(output_folder_not_quantized_hex, exist_ok=True)

# 指定要量化和輸出的層索引
# layers_to_quantize_and_output = [0, 2, 4, 6, 9, 10]  # 根據需要調整
# layers_to_quantize_and_output = [1, 3, 5, 7, 9, 10]  # 根據需要調整
layers_to_quantize_and_output = [1, 3, 5, 7, 8, 9, 10]  # 根據需要調整
# layers_to_quantize_and_output = []  # 根據需要調整

# 遍歷每一層並計算輸出，量化結果，並將結果存儲到獨立的檔案中
for i, layer in enumerate(model.layers):
    output_data = compute_layer_output(layer, input_data)

    # Save the output data to a separate txt file, with channels separated
    output_txt_file = os.path.join(output_folder_not_quantized, f'layer_{i}_output.txt')
    output_data_np = output_data.numpy()
    with open(output_txt_file, 'w') as f:
        if len(output_data_np.shape) > 2:  # For convolutional layers
            f.write(f'Layer {i} output shape: {output_data_np.shape}\n\n')
            for c in range(output_data_np.shape[-1]):  # For each channel
                f.write(f'Channel {c}:\n')
                for h in range(output_data_np.shape[1]):  # Height
                    for w in range(output_data_np.shape[2]):  # Width
                        # f.write(f'{output_data_np[0, h, w, c]:8.4f} ')
                        f.write(f'{int(output_data_np[0, h, w, c]):d} ')
                    f.write('\n')
                f.write('\n')
        else:  # For dense layers
            f.write(f'Layer {i} output shape: {output_data_np.shape}\n\n')
            for n in range(output_data_np.shape[-1]):  # For each neuron
                # f.write(f'{output_data_np[0, n]:8.4f} ')
                f.write(f'{int(output_data_np[0, n]):d} ')
            f.write('\n')
    print(f'Layer: {layer.name}, Output saved to: {output_txt_file}')

    # Save the output data to both txt and hex files
    output_txt_file = os.path.join(output_folder_not_quantized_hex, f'layer_{i}_output_hex.txt')
    # output_hex_file = os.path.join(output_folder_not_quantized, f'layer_{i}_output.hex')
    output_data_np = output_data.numpy()
    
    # Write to txt file
    with open(output_txt_file, 'w') as f:
        if len(output_data_np.shape) > 2:  # For convolutional layers
            f.write(f'Layer {i} output shape: {output_data_np.shape}\n\n')
            for c in range(output_data_np.shape[-1]):  # For each channel
                f.write(f'Channel {c}:\n')
                for h in range(output_data_np.shape[1]):  # Height
                    for w in range(output_data_np.shape[2]):  # Width
                        # Convert to 24-bit hex
                        val = int(output_data_np[0, h, w, c]) & 0xFFFFFF  # Ensure 24-bit
                        f.write(f'0x{val:06X} ')  # Write as 6-digit hex
                    f.write('\n')
                f.write('\n')
        else:  # For dense layers
            f.write(f'Layer {i} output shape: {output_data_np.shape}\n\n')
            for n in range(output_data_np.shape[-1]):  # For each neuron
                val = int(output_data_np[0, n]) & 0xFFFFFF  # Ensure 24-bit
                f.write(f'0x{val:06X} ')  # Write as 6-digit hex
            f.write('\n')

    # Write to hex file (binary format)
    # with open(output_hex_file, 'wb') as f:
    #     if len(output_data_np.shape) > 2:  # For convolutional layers
    #         for c in range(output_data_np.shape[-1]):  
    #             for h in range(output_data_np.shape[1]):  
    #                 for w in range(output_data_np.shape[2]):
    #                     val = int(output_data_np[0, h, w, c]) & 0xFFFFFF
    #                     f.write(val.to_bytes(3, byteorder='big'))  # Write as 24-bit binary
    #     else:  # For dense layers
    #         for n in range(output_data_np.shape[-1]):
    #             val = int(output_data_np[0, n]) & 0xFFFFFF
    #             f.write(val.to_bytes(3, byteorder='big'))

    # print(f'Layer: {layer.name}, Output saved to: {output_txt_file} and {output_hex_file}')

    if i in layers_to_quantize_and_output:
        quantized_output = quantize(output_data, i)
        output_file = os.path.join(output_folder, f'layer_{i}_output.hex')
        write_hex_file(output_file, quantized_output)
        print(f'Layer: {layer.name}, Output saved to: {output_file}')
        input_data = quantized_output.astype(np.float32)  # 將量化後的結果作為下一層的輸入
        # input_data = output_data  # 不量化，直接將輸出作為下一層的輸入
        # print(f"Layer {i} negative values:", input_data[input_data < 0])
    else:
        quantized_output = quantize(output_data, i)
        output_file = os.path.join(output_folder, f'layer_{i}_output.hex')
        write_hex_file(output_file, quantized_output)
        print(f'Layer: {layer.name}, Output saved to: {output_file}')
        input_data = output_data  # 不量化，直接將輸出作為下一層的輸入