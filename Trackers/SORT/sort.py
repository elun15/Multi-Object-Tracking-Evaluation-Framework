"""
    SORT: A Simple, Online and Realtime Tracker
    Copyright (C) 2016 Alex Bewley alex@dynamicdetection.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""
from __future__ import print_function

from numba import jit
import os.path
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from skimage import io
from sklearn.utils.linear_assignment_ import linear_assignment
import glob
import time
import argparse
from filterpy.kalman import KalmanFilter
import cv2
from utils import visualization
from utils.detection import Detection
import pdb


@jit
def iou(bb_test,bb_gt):
  """
  Computes IUO between two bboxes in the form [x1,y1,x2,y2]
  """
  xx1 = np.maximum(bb_test[0], bb_gt[0])
  yy1 = np.maximum(bb_test[1], bb_gt[1])
  xx2 = np.minimum(bb_test[2], bb_gt[2])
  yy2 = np.minimum(bb_test[3], bb_gt[3])
  w = np.maximum(0., xx2 - xx1)
  h = np.maximum(0., yy2 - yy1)
  wh = w * h
  o = wh / ((bb_test[2]-bb_test[0])*(bb_test[3]-bb_test[1])
    + (bb_gt[2]-bb_gt[0])*(bb_gt[3]-bb_gt[1]) - wh)
  return(o)

def convert_bbox_to_z(bbox):
  """
  Takes a bounding box in the form [x1,y1,x2,y2] and returns z in the form
    [x,y,s,r] where x,y is the centre of the box and s is the scale/area and r is
    the aspect ratio
  """
  w = bbox[2]-bbox[0]
  h = bbox[3]-bbox[1]
  x = bbox[0]+w/2.
  y = bbox[1]+h/2.
  s = w*h    #scale is just area
  r = w/float(h)
  return np.array([x,y,s,r]).reshape((4,1))

def convert_x_to_bbox(x,score=None):
  """
  Takes a bounding box in the centre form [x,y,s,r] and returns it in the form
    [x1,y1,x2,y2] where x1,y1 is the top left and x2,y2 is the bottom right
  """
  w = np.sqrt(x[2]*x[3])
  h = x[2]/w
  if(score==None):
    return np.array([x[0]-w/2.,x[1]-h/2.,x[0]+w/2.,x[1]+h/2.]).reshape((1,4))
  else:
    return np.array([x[0]-w/2.,x[1]-h/2.,x[0]+w/2.,x[1]+h/2.,score]).reshape((1,5))


class KalmanBoxTracker(object):
  """
  This class represents the intern<al state of individual tracked objects observed as bbox.
  """
  count = 0

  def __init__(self,bbox,flag_new_video):
    """
    Initialises a tracker using initial bounding box.
    """
    #define constant velocity model
    self.kf = KalmanFilter(dim_x=7, dim_z=4)
    self.kf.F = np.array([[1,0,0,0,1,0,0],[0,1,0,0,0,1,0],[0,0,1,0,0,0,1],[0,0,0,1,0,0,0],  [0,0,0,0,1,0,0],[0,0,0,0,0,1,0],[0,0,0,0,0,0,1]])
    self.kf.H = np.array([[1,0,0,0,0,0,0],[0,1,0,0,0,0,0],[0,0,1,0,0,0,0],[0,0,0,1,0,0,0]])

    self.kf.R[2:,2:] *= 10.
    self.kf.P[4:,4:] *= 1000. #give high uncertainty to the unobservable initial velocities
    self.kf.P *= 10.
    self.kf.Q[-1,-1] *= 0.01
    self.kf.Q[4:,4:] *= 0.01

    self.flag = flag_new_video

    if self.flag is 1:
        self.flag = 0
        KalmanBoxTracker.count = 1


    self.kf.x[:4] = convert_bbox_to_z(bbox)
    self.time_since_update = 0
    self.id = KalmanBoxTracker.count
    KalmanBoxTracker.count += 1
    self.history = []
    self.hits = 0
    self.hit_streak = 0
    self.age = 0
    self.clase = bbox[5]




  def update(self,bbox):
    """
    Updates the state vector with observed bbox.
    """
    self.time_since_update = 0
    self.history = []
    self.hits += 1
    self.hit_streak += 1
    self.kf.update(convert_bbox_to_z(bbox))

  def predict(self):
    """
    Advances the state vector and returns the predicted bounding box estimate.
    """
    if((self.kf.x[6]+self.kf.x[2])<=0):
      self.kf.x[6] *= 0.0
    self.kf.predict()
    self.age += 1
    if(self.time_since_update>0):
      self.hit_streak = 0
    self.time_since_update += 1
    self.history.append(convert_x_to_bbox(self.kf.x))
    return self.history[-1]

  def get_state(self):
    """
    Returns the current bounding box estimate.
    """
    return convert_x_to_bbox(self.kf.x)

  def get_clase(self):
    return self.clase


def associate_detections_to_trackers(detections,trackers,iou_threshold = 0.3):
  """
  Assigns detections to tracked object (both represented as bounding boxes)

  Returns 3 lists of matches, unmatched_detections and unmatched_trackers
  """
  if(len(trackers)==0):
    return np.empty((0,2),dtype=int), np.arange(len(detections)), np.empty((0,5),dtype=int)
  iou_matrix = np.zeros((len(detections),len(trackers)),dtype=np.float32)

  for d,det in enumerate(detections):
    for t,trk in enumerate(trackers):
      iou_matrix[d,t] = iou(det,trk)
  matched_indices = linear_assignment(-iou_matrix)

  unmatched_detections = []
  for d,det in enumerate(detections):
    if(d not in matched_indices[:,0]):
      unmatched_detections.append(d)
  unmatched_trackers = []

  for t,trk in enumerate(trackers):
    if(t not in matched_indices[:,1]):
      unmatched_trackers.append(t)

  #filter out matched with low IOU
  matches = []
  for m in matched_indices:
    if(iou_matrix[m[0],m[1]]<iou_threshold):
      unmatched_detections.append(m[0])
      unmatched_trackers.append(m[1])
    else:
      matches.append(m.reshape(1,2))
  if(len(matches)==0):
    matches = np.empty((0,2),dtype=int)
  else:
    matches = np.concatenate(matches,axis=0)

  return matches, np.array(unmatched_detections), np.array(unmatched_trackers)



class Sort(object):
  def __init__(self,max_age=1,min_hits=3):
    """
    Sets key parameters for SORT
    """
    self.max_age = max_age
    self.min_hits = min_hits
    self.trackers = []
    self.frame_count = 0
    self.new_video = 1

  def update(self,dets):
    """
    Params:
      dets - a numpy array of detections in the format [[x1,y1,x2,y2,score],[x1,y1,x2,y2,score],...]
    Requires: this method must be called once for each frame even with empty detections.
    Returns the a similar array, where the last column is the object ID.

    NOTE: The number of objects returned may differ from the number of detections provided.
    """
    self.frame_count += 1
    #get predicted locations from existing trackers.
    trks = np.zeros((len(self.trackers),5)) #de 6
    to_del = []
    ret = []
    for t,trk in enumerate(trks):
      pos = self.trackers[t].predict()[0]
      trk[:] = [pos[0], pos[1], pos[2], pos[3], 0]
      if(np.any(np.isnan(pos))):
        to_del.append(t)
    trks = np.ma.compress_rows(np.ma.masked_invalid(trks))
    for t in reversed(to_del):
      self.trackers.pop(t)
    matched, unmatched_dets, unmatched_trks = associate_detections_to_trackers(dets,trks)

    #update matched trackers with assigned detections
    for t,trk in enumerate(self.trackers):
      if(t not in unmatched_trks):
        d = matched[np.where(matched[:,1]==t)[0],0]
        trk.update(dets[d,:][0])

    #create and initialise new trackers for unmatched detections
    for i in unmatched_dets:
        trk = KalmanBoxTracker(dets[i,:], self.new_video)
        if trk.flag == 0:
            self.new_video = 0

        self.trackers.append(trk)
    i = len(self.trackers)

    for trk in reversed(self.trackers):
        d = trk.get_state()[0]
        clase = trk.get_clase()
        if((trk.time_since_update < 1) and (trk.hit_streak >= self.min_hits or self.frame_count <= self.min_hits)):
          ret.append(np.concatenate((d,[trk.id+1],[clase])).reshape(1,-1)) # +1 as MOT benchmark requires positive
        i -= 1
        #remove dead tracklet
        if(trk.time_since_update > self.max_age):
          self.trackers.pop(i)
    if(len(ret)>0):
      return np.concatenate(ret)
    return np.empty((0,5))
    
def parse_args():
    """Parse input arguments."""
    parser = argparse.ArgumentParser(description='SORT demo')
    parser.add_argument('--display', dest='display', help='Display online tracker output (slow) [False]',action='store_true')
    parser.add_argument('--input_sequence',type=str)
    parser.add_argument('--detections', type=str)
    args = parser.parse_args()
    return args


def gather_sequence_info(sequence_dir, seq_dets):
    """Gather sequence information, such as image filenames, detections, groundtruth (if available).

    :param sequence_dir: str
        Path to the sequences directory.
    :param detection_file: str
        Path to the detection file.

    :return: sequence info: dict
    A dictionary of the following sequence information:

        * sequence_name: Name of the sequence
        * image_filenames: A dictionary that maps frame indices to image
          filenames.
        * detections: A numpy array of detections in MOTChallenge format.
        * groundtruth: A numpy array of ground truth in MOTChallenge format.
        * image_size: Image size (height, width).
        * min_frame_idx: Index of the first frame.
        * max_frame_idx: Index of the last frame.
    """

    image_dir = os.path.join(sequence_dir, "img1") #append "img1"


    # whole list of image files names
    image_filenames = {int(os.path.splitext(f)[0]): os.path.join(image_dir, f) for f in os.listdir(image_dir)}

    # load npy detections file
    # detections = None
    # if detection_file is not None:
    #     detections = np.loadtxt(detection_file, delimiter=',')
    #     #detections = np.load(detection_file) # para .npy
    detections = seq_dets


    groundtruth_file = os.path.join(sequence_dir, "gt/gt.txt")
    groundtruth_file = ''

    # loag gt
    groundtruth = None

    if os.path.exists(groundtruth_file):
        groundtruth = np.loadtxt(groundtruth_file, delimiter=',')
    else:
        print("No GT file found.")

    # load image for getting size
    if len(image_filenames) > 0:
        image = cv2.imread(next(iter(image_filenames.values())), cv2.IMREAD_GRAYSCALE)
        image_size = image.shape
    else:
        image_size = None
        print("Image is empty.")

        # Get number of frames
    if len(image_filenames) > 0:
        min_frame_idx = min(image_filenames.keys())
        max_frame_idx = max(image_filenames.keys())
    else:
        min_frame_idx = int(detections[:, 0].min())
        max_frame_idx = int(detections[:, 0].max())

    # Info file path
    info_filename = os.path.join(sequence_dir, "seqinfo.ini")
    if os.path.exists(info_filename):
        with open(info_filename, "r") as f:
            line_splits = [l.split('=') for l in f.read().splitlines()[1:]]
            info_dict = dict(
                s for s in line_splits if isinstance(s, list) and len(s) == 2)

        update_ms = 1000 / int(info_dict["frameRate"])  # framete (ms)
    else:
        update_ms = None


    seq_info = {
        "sequence_name": os.path.basename(sequence_dir),
        "image_filenames": image_filenames,
        "detections": detections,
        "groundtruth": groundtruth,
        "image_size": image_size,
        "min_frame_idx": min_frame_idx,
        "max_frame_idx": max_frame_idx,
        "update_ms": update_ms
    }
    return seq_info


# Provide a list with the detections of the current frame
def create_detections(detection_mat, frame_idx, min_height=0):
    """Create detections for given frame index from the raw detection matrix.

    :param detection_mat: ndarray
        Matrix of detections. The first 10 columns of the detection matrix are
        in the standard MOTChallenge detection format. In the remaining columns
        store the feature vector associated with each detection.
    :param frame_idx: int
        The frame index.
    :param case: int
    :param min_height: Optional[int]
        A minimum detection bounding box height. Detections that are smaller
        than this value are disregarded.
    :return: detection_list: list[tracker.Detection]
        Returns detection responses at given frame index.
    """

    frame_indices = detection_mat[:, 0].astype(np.int)
    mask = frame_indices == frame_idx

    detection_list = []
    # consider only detections in such frame
    for row in detection_mat[mask]:
        row = np.array(row).reshape(1, row.shape[0])
        bbox, confidence, clase = row[0, 2:6], row[0, 6], row[0, 7] #no features


        detection_list.append(Detection(bbox, confidence, clase))

    return detection_list


if __name__ == '__main__':

  # all train
  args = parse_args()
  display = False
  if args.display:
      display = True

  sequences = []


  if args.input_sequence is None:

      datasets_path = '../../Datasets/'

      datasets = os.listdir(datasets_path)
      # whole list of image files names
      datasets_dir = [os.path.join(datasets_path, f)  for f in datasets]
      list_datasets = [(datasets_dir[i]) for i, j in enumerate(datasets_dir)]
      list_sequences = [(os.listdir(j)) for i, j in enumerate(datasets_dir)]

      #sequences = [item for sublist in sequences_list for item in sublist]
      #import itertools

      for i,j in enumerate(list_sequences):
      # do something with each list item
        for k,l in enumerate(j):
          sequences.append(os.path.join(list_datasets[i],j[k]))



  else:
      sequences.append(args.input_sequence)

  results_path = '../../Results/';
  # tracking_resultTracking/SORT/'

  # phase = 'train'
  total_time = 0.0
  total_frames = 0
  # colours = np.random.rand(32,3) #used only for display


  for seq in sequences:
    seq2 = os.path.split(seq)[0]
    name_dataset = os.path.basename(seq2)
    name_sequence = os.path.split(seq)[1]

    detections = []
    detections_path = os.path.join(results_path, 'Detections', name_dataset, name_sequence)

    if args.detections is None:
        detections = os.listdir(detections_path)
    else:
        detections.append(args.detections)

    for det in detections:

        det_file = os.path.join(detections_path, det, '%s.txt' % name_sequence)
        seq_dets = np.loadtxt(det_file, delimiter=',')  # load detections
        #seq_dets = np.loadtxt('%s/det/det.txt' % (seq), delimiter=',')  # load detections
        seq_info = gather_sequence_info(seq, seq_dets)

        result_tracking_sequence_path = os.path.join(results_path,'Tracking/SORT', name_dataset, name_sequence, det)
        if not os.path.exists(result_tracking_sequence_path): #create folder where the results files will be stored
          os.makedirs(result_tracking_sequence_path)

        if  display:
          visualizer = visualization.Visualization(seq_info, update_ms=5)
        else:
          visualizer = None

        mot_tracker = Sort() #create instance of the SORT tracker

        with open('%s/%s.txt'%(result_tracking_sequence_path,name_sequence),'w') as out_file:
          print("Processing %s. %s "%(name_sequence,det))

          for frame in range(int(seq_dets[:,0].max())):

            frame += 1 #detection and frame numbers begin at 1

            dets = seq_dets[seq_dets[:,0]==frame,2:8] # dets en frame 1 ( 4 coords blob + score)
            dets_xywh = dets.copy()
            dets[:,2:4] = dets_xywh[:,2:4] + dets[:,0:2] #convert to [x1,y1,w,h] to [x1,y1,x2,y2]

            total_frames += 1

            start_time = time.time()
            trackers = mot_tracker.update(dets) # [bbox id clase]
            cycle_time = time.time() - start_time
            total_time += cycle_time

            for d in trackers:

              print('%d,%d,%.2f,%.2f,%.2f,%.2f,1,%d,-1,-1'%(frame,d[4],d[0],d[1],d[2]-d[0],d[3]-d[1],d[5]),file=out_file)


            if visualizer:
              # Load image and generate detections (bbox, confidence + feaures)
              detections_list = create_detections(seq_dets, frame)

              image = cv2.imread(os.path.join(seq,'img1','%06d.jpg'%frame), cv2.IMREAD_COLOR)
              visualizer.set_image(image.copy())
              visualizer.draw_detections(detections_list)
              visualizer.draw_trackers(trackers)

              # gt = seq_info["groundtruth"]
              # gt_frame = gt[gt[:, 0] == frame_idx, :]
              # ids = gt_frame[:, 1]
              # boxes = gt_frame[:, 2:6]

              # vis.draw_groundtruth(ids,boxes)
              # # cv2.imshow("frame",vis.viewer.image)
              # # cv2.waitKey()
              # plt.imshow(vis.viewer.image)
              # plt.pause(0.001)
              # plt.show(block=False)

              visualizer.run()



  print("Total Tracking took: %.3f for %d frames or %.1f FPS"%(total_time,total_frames,total_frames/total_time))
  # if(display):
  #   print("Note: to get real runtime results run without the option: --display")
  


