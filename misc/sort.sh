#!/bin/bash
cd Trackers/SORT/
source /home/vpu/anaconda3/bin/activate prueba
python sort.py --input_sequence /home/vpu/MOT-Evaluation-Framework/Datasets/MOT16_test/MOT16-02 --detections gt
