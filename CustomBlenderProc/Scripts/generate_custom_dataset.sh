#!/bin/bash

function usage() {
    echo "Usage: $0 --dataset_name <name> --num_scenes <number> --yolo_conversion [0-1]"
    exit 1
}

# Function to count the number of images in a directory
count_images() {
    local dir=$1
    find "$dir" -type f -name '*.jpg' | wc -l
}

# Use the script directory as main folder
cd $(dirname $0)

# Default number of scenes to generate
num_scenes=100

# Default yolo_conversion is false
yolo_conversion=0

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dataset_name)
            if [[ -n $2 && ! $2 =~ ^- ]]; then
                dataset_name="$2"
                shift
            else
                echo "Error: --dataset_name requires a value."
                usage
            fi
            ;;
        --num_scenes)
            if [[ -n $2 && ! $2 =~ ^- ]]; then
                num_scenes="$2"
                shift
            else
                echo "Error: --num_scenes requires a value."
                usage
            fi
            ;;
        --yolo_conversion)
            if [[ $2 -eq 0 || $2 -eq 1 ]]; then
                yolo_conversion="$2"
                shift
            else
                echo "Error: --yolo_conversion must be either 0 or 1."
                usage
            fi
            ;;
        *)
            echo "Unknown parameter passed: $1"
            usage
            ;;
    esac
    shift
done

if [ -z "$dataset_name" ]; then
    echo "Error: --dataset_name is required."
    usage
fi

if [ ! -d "../datasets/$dataset_name" ]; then
    echo "../datasets/$dataset_name does not exist"
    exit 1
fi

if [ -d "../datasets/ycbv" ]; then
    echo "ATTENTION! The folder datasets/ycbv must be reserved to the script. Remove it, otherwise the script won't work."
    exit 1
fi

cp -r "../datasets/$dataset_name" "../datasets/ycbv"

# Report path
report_path="../GeneratedScenesBop/report.txt"

# Directory paths
base_dir="../GeneratedScenesBop/bop_data/ycbv/train_pbr"
blenderproc_cmd="blenderproc run ../generate_ycbv_like.py ../datasets ../BackgroundTextures ../GeneratedScenesBop/ --num_scenes=40"

current_gen_scenes=0

if [ -d $base_dir ]; then
    current_gen_scenes=$(find $base_dir -mindepth 1 -maxdepth 1 -type d | wc -l)
fi

echo "$current_gen_scenes scenes found."

# Generate scenes
for ((i=$current_gen_scenes; i<num_scenes; i++)); do
    
    # Run BlenderProc to generate the scene
    eval $blenderproc_cmd
    
    scene_dir=$(printf "%s/%06d/rgb" "$base_dir" "$i")
    
    # Count the number of images in the scene directory
    num_images=$(count_images "$scene_dir")
    
    echo $num_images >> $report_path

    # Check if the scene contains 1000 images
    if [ "$num_images" -ne 1000 ]; then
        # If not, delete the folder and regenerate the scene
        echo "Scene $i does not contain 1000 images. Regenerating..." >> $report_path
        rm -rf "$base_dir/$(printf '%06d' $i)"
        i=$((i-1))  # Decrement i to retry the current index
    else
        echo "Scene $i generated successfully with 1000 images." >> $report_path
    fi
done

cd ../GeneratedScenesBop/bop_data
mv ycbv/train_pbr/ ./train_synt/
mv ycbv/camera.json ./
rm -rf ycbv
cd ..
mv bop_data/* ./
rm -rf bop_data
cd ..

rm -rf ../datasets/ycbv

if [ $yolo_conversion -eq 1 ]; then 
    python3 yolo_conversion.py
fi
