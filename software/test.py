import numpy as np
import os
from tensorflow.keras.preprocessing.image import load_img, img_to_array
from tensorflow.keras.utils import to_categorical
from scipy.special import softmax


def load_quantized_data(filepath, shape):
    """
    加載按行存儲的量化數據並重塑
    :param filepath: 文件路徑
    :param shape: 權重或偏置的目標形狀
    :return: 重塑後的 numpy 陣列
    """
    with open(filepath, 'r') as file:
        data = [float(line.strip()) for line in file]  # 每行讀取一筆數據
    data = np.array(data, dtype=np.float32)  # 假設數據存儲為 int8
    expected_size = np.prod(shape)
    if data.size != expected_size:
        raise ValueError(f"數據大小與目標形狀不匹配: {data.size} vs {expected_size}")
    return data.reshape(shape)


def load_test_data(data_dir, target_size=(120, 120)):
    """
    加載測試數據
    :param data_dir: 測試數據資料夾路徑
    :param target_size: 圖像目標大小
    :return: 測試數據、標籤、類別索引
    """
    x_data = []
    y_data = []
    class_names = sorted(os.listdir(data_dir))  # 假設子資料夾名稱為類別名稱
    class_indices = {name: idx for idx, name in enumerate(class_names)}

    for class_name in class_names:
        class_dir = os.path.join(data_dir, class_name)
        for file_name in os.listdir(class_dir):
            file_path = os.path.join(class_dir, file_name)
            img = load_img(file_path, color_mode='grayscale', target_size=target_size)
            img_array = img_to_array(img)  # 歸一化
            x_data.append(img_array)
            y_data.append(class_indices[class_name])

    x_data = np.array(x_data)
    y_data = np.array(y_data)
    return x_data, y_data, class_indices


def relu(x):
    return np.maximum(0, x)


def conv2d(input_image, weights, bias, stride=1):
    """
    二維卷積運算
    :param input_image: 輸入圖像 (H, W, C_in)
    :param weights: 卷積權重 (K, K, C_in, C_out)
    :param bias: 偏置 (C_out,)
    :param stride: 步幅
    :return: 卷積輸出 (H_out, W_out, C_out)
    """
    H, W, C_in = input_image.shape
    K, _, _, C_out = weights.shape
    H_out = (H - K) // stride + 1
    W_out = (W - K) // stride + 1
    output = np.zeros((H_out, W_out, C_out))

    for c_out in range(C_out):
        for h in range(H_out):
            for w in range(W_out):
                region = input_image[h * stride:h * stride + K, w * stride:w * stride + K, :]
                output[h, w, c_out] = np.sum(region * weights[..., c_out]) + bias[c_out]
    return output

def max_pooling(input_tensor, pool_size=(2, 2), stride=2):
    """
    實現最大池化操作
    :param input_tensor: 輸入張量 (H, W, C)
    :param pool_size: 池化窗口大小，默認為 (2, 2)
    :param stride: 池化步幅，默認為 2
    :return: 池化後的張量 (H_out, W_out, C)
    """
    H, W, C = input_tensor.shape
    pooled_height = (H - pool_size[0]) // stride + 1
    pooled_width = (W - pool_size[1]) // stride + 1
    output_tensor = np.zeros((pooled_height, pooled_width, C))

    for h in range(pooled_height):
        for w in range(pooled_width):
            h_start = h * stride
            h_end = h_start + pool_size[0]
            w_start = w * stride
            w_end = w_start + pool_size[1]
            # 在窗口內取最大值
            output_tensor[h, w, :] = np.max(input_tensor[h_start:h_end, w_start:w_end, :], axis=(0, 1))

    return output_tensor


def model_inference(input_image):
    quantized_folder = './model_parameters'

    # 層 0：卷積層
    weights_layer_0 = load_quantized_data(
        os.path.join(quantized_folder, 'layer_0_weights.dat'),
        (5, 5, 1, 6)
    )
    biases_layer_0 = load_quantized_data(
        os.path.join(quantized_folder, 'layer_0_biases.dat'),
        (6,)
    )
    layer_0_output = relu(conv2d(input_image, weights_layer_0, biases_layer_0, stride=1))
    
    # 層 1：最大池化層
    layer_1_output = max_pooling(layer_0_output, pool_size=(2, 2), stride=2)

    # 層 2：卷積層
    weights_layer_2 = load_quantized_data(
        os.path.join(quantized_folder, 'layer_2_weights.dat'),
        (5, 5, 6, 16)
    )
    biases_layer_2 = load_quantized_data(
        os.path.join(quantized_folder, 'layer_2_biases.dat'),
        (16,)
    )
    layer_2_output = relu(conv2d(layer_1_output, weights_layer_2, biases_layer_2, stride=1))

    # 層 3：最大池化層
    layer_3_output = max_pooling(layer_2_output, pool_size=(2, 2), stride=2)

    # 層 4：卷積層
    weights_layer_4 = load_quantized_data(
        os.path.join(quantized_folder, 'layer_4_weights.dat'),
        (5, 5, 16, 32)
    )
    biases_layer_4 = load_quantized_data(
        os.path.join(quantized_folder, 'layer_4_biases.dat'),
        (32,)
    )
    layer_4_output = relu(conv2d(layer_3_output, weights_layer_4, biases_layer_4, stride=1))

    # 層 5：全局平均池化
    gap_output = np.mean(layer_4_output, axis=(0, 1))

    # 層 6：全連接層
    weights_layer_6 = load_quantized_data(
        os.path.join(quantized_folder, 'layer_6_weights.dat'),
        (128, 32)
    )
    biases_layer_6 = load_quantized_data(
        os.path.join(quantized_folder, 'layer_6_biases.dat'),
        (128,)
    )
    fc_1_output = relu(np.dot(gap_output, weights_layer_6.T) + biases_layer_6)

    # 層 7：輸出層
    weights_layer_8 = load_quantized_data(
        os.path.join(quantized_folder, 'layer_7_weights.dat'),
        (5, 128)
    )
    biases_layer_8 = load_quantized_data(
        os.path.join(quantized_folder, 'layer_7_biases.dat'),
        (5,)
    )
    logits = np.dot(fc_1_output, weights_layer_8.T) + biases_layer_8

    return softmax(logits, axis=-1)


import random

# 加載測試數據
test_data_dir = './all_data/test_resized'
x_test, y_test, class_indices = load_test_data(test_data_dir)
y_test = to_categorical(y_test, num_classes=len(class_indices))

# 隨機選擇 5 張圖片
num_samples = 5
random_indices = random.sample(range(len(x_test)), num_samples)
random_images = x_test[random_indices]
random_labels = y_test[random_indices]

correct_predictions = 0

print(f"隨機選取的 {num_samples} 張測試圖片進行推理：")
for i, (img, label) in enumerate(zip(random_images, random_labels)):
    img = img.reshape(120, 120, 1)  # 確保輸入形狀正確
    prediction = model_inference(img)  # 模型推理
    predicted_label = np.argmax(prediction)
    true_label = np.argmax(label)

    # 結果輸出
    print(f"第 {i+1} 張圖片：")
    print(f"    真實標籤：{list(class_indices.keys())[true_label]}")
    print(f"    預測標籤：{list(class_indices.keys())[predicted_label]}")
    print(f"    預測概率分佈：{prediction}")

    # 計算準確率
    if predicted_label == true_label:
        correct_predictions += 1

accuracy = correct_predictions / num_samples
print(f"隨機 5 張圖片的準確率：{accuracy:.2%}")

