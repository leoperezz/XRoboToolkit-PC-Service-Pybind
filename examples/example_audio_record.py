"""Record the PICO microphones to a standard PCM WAV file."""

import argparse
import wave

import xrobotoolkit_sdk as xrt


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("output", nargs="?", default="pico_microphone.wav")
    args = parser.parse_args()

    xrt.init()
    wav = None
    try:
        print("Enable Audio in the PICO UI. Press Ctrl+C to finish.")
        while True:
            chunk = xrt.get_audio_frame(timeout_ms=1000, latest=False)
            if chunk is None:
                continue
            if wav is None:
                wav = wave.open(args.output, "wb")
                wav.setnchannels(chunk["channels"])
                wav.setsampwidth(2)  # signed PCM16 little-endian
                wav.setframerate(chunk["sample_rate"])
            wav.writeframesraw(chunk["data"])
    except KeyboardInterrupt:
        pass
    finally:
        if wav is not None:
            wav.close()
        xrt.close()
        print(f"Saved {args.output}")


if __name__ == "__main__":
    main()
