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
        git clone https://github.com/XR-Robotics/XRoboToolkit-PC-Service.git "$SCRIPT_DIR/tmp/XRoboToolkit-PC-Service"
    fi
    SERVICE_ROOT="$SCRIPT_DIR/tmp/XRoboToolkit-PC-Service"
fi

cd "$SERVICE_ROOT/RoboticsService/PXREARobotSDK"
bash build.sh
cd "$SCRIPT_DIR"

mkdir -p lib
mkdir -p include
mkdir -p include/nlohmann
cp "$SERVICE_ROOT/RoboticsService/PXREARobotSDK/PXREARobotSDK.h" include/
cp "$SERVICE_ROOT/RoboticsService/PXREARobotSDK/nlohmann/"*.hpp include/nlohmann/
cp "$SERVICE_ROOT/RoboticsService/PXREARobotSDK/build/libPXREARobotSDK.so" lib/
# rm -rf tmp

# Build the project
if [[ "$CONDA_DEFAULT_ENV" != "" ]]; then
    conda install -c conda-forge pybind11 -y
else
    python -m pip install pybind11
fi

pip uninstall -y xrobotoolkit_sdk
python setup.py install
