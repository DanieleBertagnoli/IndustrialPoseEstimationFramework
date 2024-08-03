cd $(dirname $0)

./convert_dataset.sh

sudo docker run --entrypoint= -v $(pwd)/../../CustomPoET:/opt/project \
    -v $(pwd)/../../Datasets/GeneratedScenesBop/test_all:/opt/project/PoetDataset/test_all \
    -v $(pwd)/../../Datasets/GeneratedScenesBop/train:/opt/project/PoetDataset/train \
    --shm-size=10g --rm --gpus all aaucns/poet:latest python -u /opt/project/main.py