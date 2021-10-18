FROM ubuntu:18.04 as build
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        g++ \
        make \
        cmake \
        curl \
        unzip \
        libopencv-dev \
        python3 \
        python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir torch==1.9.1+cpu torchvision==0.10.1+cpu -f https://download.pytorch.org/whl/torch_stable.html

WORKDIR /code
RUN curl https://download.pytorch.org/libtorch/cpu/libtorch-shared-with-deps-1.9.1%2Bcpu.zip --output libtorch.zip \
    && unzip libtorch.zip -d /assets \
    && rm -rf libtorch.zip

COPY . ./
RUN python3 /code/models/resnet/resnet.py \
    && mv /code/models/resnet/resnet_model_cpu.pth /assets \
    && mv /code/models/resnet/labels.txt /assets

WORKDIR /code/inference-cpp/cnn-classification
RUN ./build.sh && mv predict /assets


FROM ubuntu:18.04
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libopencv-dev \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /assets /assets

ENTRYPOINT [ "sh", "-c", "/assets/predict /mnt/$0 /assets/resnet_model_cpu.pth /assets/labels.txt false" ]
