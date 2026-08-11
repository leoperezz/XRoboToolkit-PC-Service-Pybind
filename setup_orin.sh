set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [[ "$CONDA_DEFAULT_ENV" != "" ]]; then
    conda install -c conda-forge libstdcxx-ng -y
fi

SERVICE_ROOT="$SCRIPT_DIR/../XRoboToolkit-PC-Service"
if [[ ! -d "$SERVICE_ROOT/RoboticsService/PXREARobotSDK" ]]; then
    mkdir -p "$SCRIPT_DIR/tmp"
    if [[ ! -d "$SCRIPT_DIR/tmp/XRoboToolkit-PC-Service" ]]; then
        git clone -b orin https://github.com/XR-Robotics/XRoboToolkit-PC-Service.git "$SCRIPT_DIR/tmp/XRoboToolkit-PC-Service"
    fi
    SERVICE_ROOT="$SCRIPT_DIR/tmp/XRoboToolkit-PC-Service"
fi

cd "$SERVICE_ROOT/RoboticsService/PXREARobotSDK"
bash build_aarch64.sh
cd "$SCRIPT_DIR"

mkdir -p lib/aarch64
mkdir -p include/aarch64
mkdir -p include/aarch64/nlohmann
cp "$SERVICE_ROOT/RoboticsService/PXREARobotSDK/PXREARobotSDK.h" include/aarch64/
cp "$SERVICE_ROOT/RoboticsService/PXREARobotSDK/nlohmann/"*.hpp include/aarch64/nlohmann/
cp "$SERVICE_ROOT/RoboticsService/PXREARobotSDK/build/libPXREARobotSDK.so" lib/aarch64/
# rm -rf tmp

# Build the project
if [[ "$CONDA_DEFAULT_ENV" != "" ]]; then
    conda install -c conda-forge pybind11 -y
else
    python -m pip install pybind11
fi

pip uninstall -y xrobotoolkit_sdk
python setup.py install
