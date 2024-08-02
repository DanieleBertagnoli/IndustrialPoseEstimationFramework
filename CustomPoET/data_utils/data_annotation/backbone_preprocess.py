import sys, os
sys.path.append(os.path.dirname(__file__) + '/../../models/yolov4/yolo')

import torch

from yolo_utils.datasets import LoadImages
from backbone_models.models import *
from backbone_models.experimental import *
from yolo_utils.datasets import *
from yolo_utils.general import *


class YoloInference:
    def __init__(self, weights_path, cfg_path, img_size=640) -> None:
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        
        # Load model
        self.model = Darknet(cfg_path, img_size).to(self.device)
        try:
            self.model.load_state_dict(torch.load(weights_path, map_location=self.device)['model'])
        except:
            load_darknet_weights(self.model, weights_path)
        
        self.model.half()  # to FP16 if using CUDA
        self.model.eval()

    def init_dataset(self, source_path, img_size=640):
        self.dataset = source_path
        if source_path[-1] != '/':
            self.dataset += '/'
        self.img_size = img_size

    def detect(self, save_file_path) -> None:

        detections = ''
        for sequence_id in os.listdir(self.dataset):
            root = f'{self.dataset}/{sequence_id}/rgb'

            images = LoadImages(root, self.img_size)

            for path, img, im0s, vid_cap in images:
                img = torch.from_numpy(img).to(self.device).half()  # uint8 to fp16/32
                img /= 255.0  # 0 - 255 to 0.0 - 1.0
                if img.ndimension() == 3:
                    img = img.unsqueeze(0)

                with torch.no_grad():
                    pred = self.model(img, augment=False)[0]
                    pred = non_max_suppression(pred, 0.4, 0.5, agnostic=True)
                
                print()
                # Print prediction for debugging
                if pred[0] != None:
                    file_name = os.path.basename(path)
                    sequence_id = path.split('/')[-3]
                    detections += f'{self.dataset}{sequence_id}/rgb/{file_name}\n'

                # Free up CUDA memory
                del img, pred
                torch.cuda.empty_cache()

        with open(save_file_path, 'a') as f:
            f.write(detections)
            f.close()

if __name__ == '__main__':
    yolo_inference = YoloInference('/opt/project/PreTrained/best.pt', '/opt/project/configs/yolo.cfg')
    yolo_inference.init_dataset('/TmpDataset/train/train_synt/')
    yolo_inference.detect('/opt/project/tmp.txt')