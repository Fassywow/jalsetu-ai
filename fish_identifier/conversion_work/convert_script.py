
import torch
import torch.onnx
import onnx
from onnx2tf import convert
import os
import sys

# Add current directory to path to find models module
sys.path.append(os.getcwd())

from models.efficientnet_b0 import EfficientNetB0Classifier

def convert_model():
    print("🚀 Starting conversion process...")
    
    # Paths
    model_path = "efficientnet_best9912.pth"
    onnx_path = "fish_freshness.onnx"
    tflite_path = "fish_freshness.tflite"
    
    # 1. Load PyTorch Model
    print(f"📦 Loading PyTorch model from {model_path}...")
    device = torch.device("cpu")
    model = EfficientNetB0Classifier(train_base=False)
    
    try:
        # Load state dict
        state_dict = torch.load(model_path, map_location=device)
        model.load_state_dict(state_dict)
        model.eval()
        print("✅ Model loaded successfully")
    except Exception as e:
        print(f"❌ Failed to load model: {e}")
        return

    # 2. Export to ONNX
    print("🔄 Exporting to ONNX...")
    dummy_input = torch.randn(1, 3, 224, 224)
    
    try:
        torch.onnx.export(
            model,
            dummy_input,
            onnx_path,
            verbose=False,
            input_names=['input'],
            output_names=['output'],
            opset_version=11
        )
        print(f"✅ ONNX model saved to {onnx_path}")
    except Exception as e:
        print(f"❌ Failed to export to ONNX: {e}")
        return

    # 3. Convert ONNX to TFLite using onnx2tf
    print("🔄 Converting ONNX to TFLite...")
    try:
        # onnx2tf handles the conversion and optimization
        # It's usually run as a CLI, but we can call it via os.system or subprocess
        # Or use the python API if available. onnx2tf has a convert function but it's often easier to run the command.
        
        # Using os.system for simplicity as onnx2tf is a CLI tool primarily
        cmd = f"onnx2tf -i {onnx_path} -o {os.path.dirname(tflite_path)} -osd"
        ret = os.system(cmd)
        
        if ret == 0:
             # onnx2tf creates a directory or file depending on version/args. 
             # Usually it creates a saved_model and .tflite in the output dir.
             # Let's check for the tflite file.
             # onnx2tf output usually defaults to the input filename with .tflite extension in the output folder
             
             # Actually, let's use a simpler approach with tflite_support or just tensorflow if onnx2tf is complex to invoke from script
             # But onnx2tf is robust.
             
             # Alternative: Use standard TF converter from ONNX (if onnx-tf installed) or just onnx2tf CLI.
             pass
        else:
            print("❌ onnx2tf failed via system call")
            
    except Exception as e:
        print(f"❌ Failed to convert to TFLite: {e}")

if __name__ == "__main__":
    convert_model()
