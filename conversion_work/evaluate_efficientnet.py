# evaluate/evaluate_efficientnet_b0.py

import sys, os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

import torch
import numpy as np
from PIL import Image
import matplotlib.pyplot as plt
import seaborn as sns
from torch.utils.data import DataLoader
from torchvision import transforms
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    confusion_matrix, roc_auc_score
)

from models.efficientnet_b0 import EfficientNetB0Classifier

class ImageNpyDataset(torch.utils.data.Dataset):
    def __init__(self, paths_file, labels_file, img_size=(224, 224)):
        self.image_paths = np.load(paths_file, allow_pickle=True).astype(str)
        self.labels = np.load(labels_file, allow_pickle=True).astype(np.float32)
        self.transform = transforms.Compose([
            transforms.Resize(img_size),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406],
                                 [0.229, 0.224, 0.225])
        ])

    def __len__(self):
        return len(self.image_paths)

    def __getitem__(self, idx):
        image = Image.open(self.image_paths[idx]).convert("RGB")
        image = self.transform(image)
        label = torch.tensor([self.labels[idx]], dtype=torch.float32)
        return image, label

def evaluate(model_path="results_efficientnet_b0/efficientnet_best9912.pth"):
    os.makedirs("results", exist_ok=True)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    test_ds = ImageNpyDataset("test_paths.npy", "test_labels.npy")
    test_loader = DataLoader(test_ds, batch_size=32)

    model = EfficientNetB0Classifier(train_base=False)
    model.load_state_dict(torch.load(model_path, map_location=device))
    model.to(device)
    model.eval()

    y_true, y_pred, y_prob = [], [], []
    with torch.no_grad():
        for x, y in test_loader:
            x = x.to(device)
            out = model(x).squeeze()
            probs = out.cpu().numpy().tolist()
            preds = (out > 0.5).float().cpu().numpy().tolist()
            y_true.extend(y.squeeze().numpy().tolist())
            y_pred.extend(preds)
            y_prob.extend(probs)

    y_true = np.array(y_true)
    y_pred = np.array(y_pred)
    y_prob = np.array(y_prob)

    acc = accuracy_score(y_true, y_pred)
    prec = precision_score(y_true, y_pred)
    rec = recall_score(y_true, y_pred)
    f1 = f1_score(y_true, y_pred)
    auc = roc_auc_score(y_true, y_prob)

    print("\n📊 EfficientNetB0 Test Metrics:")
    print(f"Accuracy : {acc:.4f}")
    print(f"Precision: {prec:.4f}")
    print(f"Recall   : {rec:.4f}")
    print(f"F1 Score : {f1:.4f}")
    print(f"AUC      : {auc:.4f}")

    # Bar Chart
    metrics = {"Accuracy": acc, "Precision": prec, "Recall": rec, "F1 Score": f1, "AUC": auc}
    plt.figure()
    sns.barplot(x=list(metrics.keys()), y=list(metrics.values()))
    plt.ylim(0, 1)
    plt.title("EfficientNetB0 Test Metrics")
    plt.savefig("results/eval_metrics_efficientnetb0.png", dpi=300, bbox_inches="tight")

    # Confusion Matrix
    cm = confusion_matrix(y_true, y_pred)
    plt.figure()
    sns.heatmap(cm, annot=True, fmt="d", cmap="Blues",
                xticklabels=["Fresh", "Not Fresh"],
                yticklabels=["Fresh", "Not Fresh"])
    plt.xlabel("Predicted")
    plt.ylabel("Actual")
    plt.title("EfficientNetB0 Confusion Matrix")
    plt.savefig("results/confusion_matrix_efficientnetb0.png", dpi=300, bbox_inches="tight")

if __name__ == "__main__":
    evaluate()
