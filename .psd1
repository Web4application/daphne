wsl --install
sudo apt update
sudo apt install -y git build-essential cmake clang lld python3 python3-pip
./bin/daphne scripts/examples/hello_world.daphne
