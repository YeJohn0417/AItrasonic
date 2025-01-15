import os
import numpy as np

# 定義輸入和輸出的資料夾
input_dir = "model_parameters"  # 原始參數存放資料夾
output_dir = "model_parameters_quantized"  # 量化後的參數存放資料夾
os.makedirs(output_dir, exist_ok=True)  # 確保輸出資料夾存在

# 定義量化範圍
quantized_min = -128  # INT8 的最小值
quantized_max = 127   # INT8 的最大值

# 對每層參數進行量化並保存
for filename in os.listdir(input_dir):
    # if filename.endswith(".dat") and "quantized" not in filename:  # 避免重複量化
        input_file = os.path.join(input_dir, filename)  # 完整路徑
        output_file = os.path.join(output_dir, filename.replace(".dat", "_quantized.dat"))

        # 載入原始參數
        weights = np.loadtxt(input_file, delimiter=',')
        
        # 計算量化參數
        real_min = weights.min()
        real_max = weights.max()
        scale = (real_max - real_min) / (quantized_max - quantized_min)
        zero_point = -real_min / scale

        # 量化
        quantized_weights = np.round((weights - real_min) / scale).astype(np.int8)

        # 保存量化後的參數
        np.savetxt(output_file, quantized_weights, fmt='%d')
        print(f"量化完成: {filename} -> {output_file}")

# 確保輸出資料夾已完成填充
print(f"所有檔案已量化並存儲於資料夾: {output_dir}")
