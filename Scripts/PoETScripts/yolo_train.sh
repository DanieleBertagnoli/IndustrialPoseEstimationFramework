cd $(dirname $0)

sudo docker run --entrypoint= -v $(pwd)/../../CustomPoET:/opt/project \
    -v $(pwd)/../../Datasets/YoloDatasetV2/:/YoloDataset \
    --shm-size=10g --rm --gpus all aaucns/poet:latest python \
    -u /opt/project/models/yolov4/yolo/train.py