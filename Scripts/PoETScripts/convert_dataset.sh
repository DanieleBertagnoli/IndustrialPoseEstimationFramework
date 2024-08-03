cd $(dirname $0)

sudo docker run --entrypoint= -v $(pwd)/../../CustomPoET:/opt/project \
    -v $(pwd)/../../Datasets/GeneratedScenesBop/:/TmpDataset \
    --shm-size=10g --rm --gpus all aaucns/poet:latest python \
    -u /opt/project/data_utils/data_annotation/ycbv2poet.py