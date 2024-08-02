#!/bin/bash

# Function to clean up Docker container
cleanup() {
    echo "Stopping Docker container..."
    docker stop $CONTAINER_ID
    exit 0
}

# Set up trap to call cleanup on script exit
trap cleanup SIGINT SIGTERM

# Run Docker container in the foreground
sudo docker run --entrypoint= -v ./PoETMod:/opt/project --device /dev/video0:/dev/video0 \
    -v ./SyntheticVideoGeneration/Data/Datasets/YoloDatasetV2/:/YoloDataset \
    --rm --gpus all -p 9999:9999 aaucns/poet:latest \
    python -u /opt/project/models/yolov4/yolo/detect.py &

# Capture the Docker container ID
CONTAINER_ID=$!

# Wait for the container to start up
sleep 10

echo "Starting client"

# Run the Python client
python3 ./PoETMod/Scripts/yolo_inference_client.py

# Wait for the container to exit
wait $CONTAINER_ID
