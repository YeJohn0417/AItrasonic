import os

# def dat_to_hex(dat_file_path, hex_file_path):
#     with open(dat_file_path, 'rb') as dat_file:
#         data = dat_file.read()
#     with open(hex_file_path, 'w') as hex_file:
#         hex_file.write(data.hex())

# def text_dat_to_hex(dat_file_path, hex_file_path):
#     with open(dat_file_path, 'r', encoding='utf-8') as dat_file:
#         data = dat_file.read()
#     with open(hex_file_path, 'w', encoding='utf-8') as hex_file:
#         hex_file.write(data.encode('utf-8').hex())

# def number_dat_to_hex(dat_file_path, hex_file_path):
#     with open(dat_file_path, 'r', encoding='utf-8') as dat_file:
#         data = dat_file.read().split()
#     hex_data = '\n'.join(format(int(number), '02x') for number in data)
#     with open(hex_file_path, 'w', encoding='utf-8') as hex_file:
#         hex_file.write(hex_data)

def number_to_twos_complement_hex(number, bit_length=8):
    if number < 0:
        number = (1 << bit_length) + number
    return format(number, '02x')

def number_dat_to_hex(dat_file_path, hex_file_path):
    with open(dat_file_path, 'r', encoding='utf-8') as dat_file:
        data = dat_file.read().split()
    hex_data = '\n'.join(number_to_twos_complement_hex(int(number)) for number in data)
    with open(hex_file_path, 'w', encoding='utf-8') as hex_file:
        hex_file.write(hex_data)

def convert_folder(dat_folder_path, hex_folder_path):
    if not os.path.exists(hex_folder_path):
        os.makedirs(hex_folder_path)
    for filename in os.listdir(dat_folder_path):
        if filename.endswith('.dat'):
            dat_file_path = os.path.join(dat_folder_path, filename)
            hex_file_path = os.path.join(hex_folder_path, filename.replace('.dat', '.hex'))
            # dat_to_hex(dat_file_path, hex_file_path)
            # text_dat_to_hex(dat_file_path, hex_file_path)
            number_dat_to_hex(dat_file_path, hex_file_path)
            print(f'Converted {dat_file_path} to {hex_file_path}')

# 使用範例
dat_folder_path = './model_parameters_quantized'
hex_folder_path = './model_parameters_quantized_hex_all'
convert_folder(dat_folder_path, hex_folder_path)
# Define the order of weight files
weight_files_order = [
    'layer_0_weights_quantized.hex',
    'layer_2_weights_quantized.hex',
    'layer_4_weights_quantized.hex',
    'layer_6_weights_quantized.hex',
    'layer_9_weights_quantized.hex',
    'layer_10_weights_quantized.hex'
]

# Define the order of bias files
bias_files_order = [
    'layer_0_biases_quantized.hex',
    'layer_2_biases_quantized.hex',
    'layer_4_biases_quantized.hex',
    'layer_6_biases_quantized.hex',
    'layer_9_biases_quantized.hex',
    'layer_10_biases_quantized.hex'
]

# Combine weights in specified order
combined_weights_path = os.path.join(hex_folder_path, 'combined_weights.hex')
with open(combined_weights_path, 'w', encoding='utf-8') as combined_file:
    for filename in weight_files_order:
        file_path = os.path.join(hex_folder_path, filename)
        if os.path.exists(file_path):
            with open(file_path, 'r', encoding='utf-8') as hex_file:
                combined_file.write(hex_file.read() + '\n')
print(f'Combined all weights into {combined_weights_path}')

# Combine biases in specified order
combined_biases_path = os.path.join(hex_folder_path, 'combined_biases.hex')
with open(combined_biases_path, 'w', encoding='utf-8') as combined_file:
    for filename in bias_files_order:
        file_path = os.path.join(hex_folder_path, filename)
        if os.path.exists(file_path):
            with open(file_path, 'r', encoding='utf-8') as hex_file:
                combined_file.write(hex_file.read() + '\n')
print(f'Combined all biases into {combined_biases_path}')