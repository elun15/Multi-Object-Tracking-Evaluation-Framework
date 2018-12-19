#!/bin/bash
cd Trackers/SORT/
source /home/vpu/anaconda3/bin/activate prueba
python sort.py --input_sequence /home/vpu/MOT-Evaluation-Framework/Datasets/MOT16_train/MOT16-04 --detections p0.5_r0.5_s4_s2