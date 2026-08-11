"""Receive and decode the PICO front-camera stream without blocking poses.

Install the optional display dependencies with:
    pip install av opencv-python
"""

import av
import cv2
import xrobotoolkit_sdk as xrt


def main():
    decoder = av.CodecContext.create("h264", "r")
    xrt.init()
    try:
        while True:
            # Ordered access is important for an inter-frame H.264 stream.
            camera_packet = xrt.get_camera_frame(timeout_ms=1000, latest=False)
            if camera_packet is None:
                continue

            for encoded_packet in decoder.parse(camera_packet["data"]):
                for image in decoder.decode(encoded_packet):
                    bgr = image.to_ndarray(format="bgr24")
                    cv2.imshow("PICO front camera", bgr)

            # Pose getters remain independent and can be sampled at any rate.
            headset_pose = xrt.get_headset_pose()
            if cv2.waitKey(1) & 0xFF == ord("q"):
                break
    finally:
        xrt.close()
        cv2.destroyAllWindows()


if __name__ == "__main__":
    main()
