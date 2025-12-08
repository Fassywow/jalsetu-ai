import sys
import os
import torch
import gradio as gr
from PIL import Image
from torchvision import transforms
import torch.nn.functional as F

# Add current directory to path to find models module
sys.path.append(os.getcwd())

from models.efficientnet_b0 import EfficientNetB0Classifier

# Constants
MODEL_PATH = "efficientnet_best9912.pth"
IMG_SIZE = (224, 224)

# Load Model
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model = EfficientNetB0Classifier(train_base=False)

try:
    state_dict = torch.load(MODEL_PATH, map_location=device)
    model.load_state_dict(state_dict)
    model.to(device)
    model.eval()
    print("✅ Model loaded successfully")
except Exception as e:
    print(f"❌ Failed to load model: {e}")
    sys.exit(1)

# Transform
transform = transforms.Compose([
    transforms.Resize(IMG_SIZE),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225])
])

def predict_freshness(image):
    if image is None:
        return "Please upload an image."
    
    try:
        # Preprocess
        img_tensor = transform(image).unsqueeze(0).to(device)
        
        # Inference
        with torch.no_grad():
            output = model(img_tensor).squeeze()
            prob = output.item()
            
        # 0 = Fresh, 1 = Stale (based on previous analysis of the code)
        # If prob > 0.5 -> Stale
        # If prob <= 0.5 -> Fresh
        
        is_fresh = prob <= 0.5
        confidence = 1.0 - prob if is_fresh else prob
        
        label = "Fresh 🐟" if is_fresh else "Stale 🤢"
        return {
            "Fresh": 1.0 - prob,
            "Stale": prob
        }
        
    except Exception as e:
        return f"Error: {e}"

# Gradio Interface
iface = gr.Interface(
    fn=predict_freshness,
    inputs=gr.Image(type="pil"),
    outputs=gr.Label(num_top_classes=2),
    title="Fish Freshness Checker (PyTorch Model)",
    description="Upload a fish eye/gill image to check freshness using the EfficientNetB0 model."
)

if __name__ == "__main__":
    iface.launch(share=True)
