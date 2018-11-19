# vim: expandtab:ts=4:sw=4
import numpy as np
import colorsys
from .image_viewer import ImageViewer
import scipy.misc
from PIL import Image
import cv2


def create_unique_color_float(tag, hue_step=0.41):
    """Create a unique RGB color code for a given track id (tag).

    The color code is generated in HSV color space by moving along the
    hue angle and gradually changing the saturation.

    Parameters
    ----------
    tag : int
        The unique target identifying tag.
    hue_step : float
        Difference between two neighboring color codes in HSV space (more
        specifically, the distance in hue channel).

    Returns
    -------
    (float, float, float)
        RGB color code in range [0, 1]

    """
    h, v = (tag * hue_step) % 1, 1. - (int(tag * hue_step) % 4) / 5.
    r, g, b = colorsys.hsv_to_rgb(h, 1., v)
    return r, g, b


def create_unique_color_uchar(tag, hue_step=0.41):
    """Create a unique RGB color code for a given track id (tag).

    The color code is generated in HSV color space by moving along the
    hue angle and gradually changing the saturation.

    Parameters
    ----------
    tag : int
        The unique target identifying tag.
    hue_step : float
        Difference between two neighboring color codes in HSV space (more
        specifically, the distance in hue channel).

    Returns
    -------
    (int, int, int)
        RGB color code in range [0, 255]

    """
    r, g, b = create_unique_color_float(tag, hue_step)
    return int(255*r), int(255*g), int(255*b)



class Visualization(object):
    """
    This class shows tracking output in an OpenCV image viewer.
    """

    def __init__(self, seq_info, update_ms):
        image_shape = seq_info["image_size"][::-1]
        aspect_ratio = float(image_shape[1]) / image_shape[0]
        image_shape = 1024, int(aspect_ratio * 1024)
        self.viewer = ImageViewer(update_ms, image_shape, "Figure %s" % seq_info["sequence_name"])
        self.viewer.thickness = 3
        self.frame_idx = seq_info["min_frame_idx"]
        self.last_idx = seq_info["max_frame_idx"]

    def run(self):
        self.viewer.run()



    def set_image(self, image):
        self.viewer.image = image

    def draw_groundtruth(self, track_ids, boxes,classes):
        self.viewer.thickness = 2
        for track_id, box,clase in zip(track_ids, boxes,classes):
            # self.viewer.color = create_unique_color_uchar(track_id)
            if clase == 4.0: #car
                self.viewer.color = 220, 20, 60
                self.viewer.rectangle(*box.astype(np.int), label=str(int(track_id)))
            elif clase == 9.0: #bus
                self.viewer.color = 255,140, 0
                self.viewer.rectangle(*box.astype(np.int), label=str(int(track_id)))
            elif clase == 6.0: #truck
                self.viewer.color = 32, 178, 170
                self.viewer.rectangle(*box.astype(np.int), label=str(int(track_id)))
            elif clase == 1.0: #pedestrian
                self.viewer.color = 34, 139, 34
                self.viewer.rectangle(*box.astype(np.int), label=str(int(track_id)))
            elif clase == 5.0: #van
                self.viewer.color = 255, 215, 0
                self.viewer.rectangle(*box.astype(np.int), label=str(int(track_id)))
            elif clase == 7.0: #van
                self.viewer.color = 255, 105, 180
                self.viewer.rectangle(*box.astype(np.int), label=str(int(track_id)))


    def draw_detections(self, detections):
        self.viewer.thickness = 1
        self.viewer.color = 0, 0, 255
        for i, detection in enumerate(detections):
            self.viewer.rectangle(*detection.tlwh)

    def draw_trackers(self, tracks):
        self.viewer.thickness = 2
        for track in tracks:
            # if not track.is_confirmed() or track.time_since_update > 0:
            #     continue
            self.viewer.color = create_unique_color_uchar(track.track_id)
            self.viewer.rectangle(*track.to_tlwh().astype(np.int), label=str(track.track_id))
            # self.viewer.gaussian(track.mean[:2], track.covariance[:2, :2],
            #                      label="%d" % track.track_id)

    def save_image(self, name):
        #im=Image.fromarray(self.viewer.image).convert('RGB')
        #scipy.misc.imsave(str(name),im)
        cv2.imwrite(name,self.viewer.image)
