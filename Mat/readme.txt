.mat descriptions

- sequences.mat: Contains info about the sequences in the framework
        sequence.dataset =  list[sequence name, path, dataset_path, detections_path]

- results_tracking.mat: Contains tracking results for each et of detections, sequences and dataset
        results_tracking.detection.tracker.dataset = [sequence_name, path, result(mat) ]

- results_eval_tracking.mat: Contains evaluation metrics of tracking results
        results_tracking.detection.tracker.dataset = [sequence_name, path, result(mat), metrics_Class, metrics_allClasses ]

- detections_performance.mat: contains P, R, det/frame, GT/frame for every sequence and detector
        performances.dataset.detector = mat[name sequence, P, R, det/frame, gt/frame]

- detections_info.mat: Contains datasets, detectors and sequences names 
        detections.dataset.detector = list of sequences name