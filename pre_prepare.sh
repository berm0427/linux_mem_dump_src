#!/bin/bash

# 메모리 덤프 과정에서의 권한 부족 문제를 해결하기 위한 조치


sudo chown root:root *.sh

sudo chmod 4711 *.sh

echo "plz prepare1.sh for next!"
