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
sudo docker run --entrypoint= -v ./PoETMod:/opt/project -v ./SyntheticVideoGeneration/Data/Datasets/ThalesDataset/GeneratedScenesBop/train/train_synt/0002/rgb:/data/0000 \
    -p 9999:9999 --shm-size=10g --rm --gpus all aaucns/poet:latest python -u /opt/project/poet_inference.py &

# Capture the Docker container ID
CONTAINER_ID=$!

# Wait for the container to start up
sleep 10

echo "Starting client"

# Run the Python client
python3 ./PoETMod/Scripts/poet_inference_client.py

# Wait for the container to exit
wait $CONTAINER_ID
