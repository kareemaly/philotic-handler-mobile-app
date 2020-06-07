FROM ubuntu:latest

WORKDIR /apps

# Installation of flutter
ENV FLUTTER_VERSION_TYPE beta
ENV FLUTTER_VERSION 1.18.0-11.1.pre-beta

RUN apt-get update \
  && apt-get install -y libglu1-mesa git curl unzip wget xz-utils lib32stdc++6 \
  && apt-get clean
RUN wget https://storage.googleapis.com/flutter_infra/releases/${FLUTTER_VERSION_TYPE}/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz
RUN tar xf flutter_linux_${FLUTTER_VERSION}.tar.xz

ENV PATH ${PATH}:/apps/flutter/bin

# Installation of android sdk
RUN apt-get install -y openjdk-8-jdk

RUN mkdir sdk && \
    cd sdk && \
    wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
    unzip sdk-tools-linux-4333796.zip

# Silence warning.
RUN mkdir -p ~/.android
RUN touch ~/.android/repositories.cfg

ENV PATH ${PATH}:/apps/sdk/tools:/apps/sdk/tools/bin

RUN yes "y" | "/apps/sdk/tools/bin/sdkmanager" "tools" > /dev/null
RUN yes "y" | "/apps/sdk/tools/bin/sdkmanager" "build-tools;28.0.3" > /dev/null
RUN yes "y" | "/apps/sdk/tools/bin/sdkmanager" "platforms;android-28" > /dev/null
RUN yes "y" | "/apps/sdk/tools/bin/sdkmanager" "platform-tools" > /dev/null
RUN yes "y" | "/apps/sdk/tools/bin/sdkmanager" "extras;android;m2repository" > /dev/null
RUN yes "y" | "/apps/sdk/tools/bin/sdkmanager" "extras;google;m2repository" > /dev/null
RUN yes "y" | "/apps/sdk/tools/bin/sdkmanager" "patcher;v4" > /dev/null

ENV ANDROID_HOME=/apps/sdk

RUN flutter precache

COPY . philotic

RUN mkdir /apps/keys && \
    keytool -genkey -v \
        -keystore /apps/keys/qa_key.jks \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -alias qa_key \
        -noprompt \
        -dname "CN=Kareem, OU=KareemDev, O=Kareem, L=Portsaid, S=Egypt, C=EGY" \
        -storepass "1234567890" \
        -keypass "1234567890"

RUN echo 'storePassword=1234567890\n\
keyPassword=1234567890\n\
keyAlias=qa_key\n\
storeFile=/apps/keys/qa_key.jks\n'\
> philotic/android/key.properties

RUN cd philotic && \
    flutter pub get

CMD cd philotic && flutter build apk --split-per-abi
