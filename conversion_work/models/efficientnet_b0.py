# models/efficientnet_b0.py

import torch
import torch.nn as nn
from torchvision import models

class EfficientNetB0Classifier(nn.Module):
    def __init__(self, train_base: bool = False):
        """
        Initialize EfficientNetB0-based binary classifier.
        :param train_base: If True, allows fine-tuning the base model.
        """
        super().__init__()
        self.base_model = models.efficientnet_b0(weights=models.EfficientNet_B0_Weights.DEFAULT)

        for param in self.base_model.features.parameters():
            param.requires_grad = train_base

        self.classifier = nn.Sequential(
            nn.BatchNorm1d(1280),
            nn.Dropout(0.5),
            nn.Linear(1280, 128),
            nn.ReLU(),
            nn.BatchNorm1d(128),
            nn.Dropout(0.5),
            nn.Linear(128, 1),
            nn.Sigmoid()
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """
        Forward pass through the network.
        :param x: Input image tensor
        :return: Output probability
        """
        x = self.base_model.features(x)
        x = self.base_model.avgpool(x)
        x = torch.flatten(x, 1)
        return self.classifier(x)
