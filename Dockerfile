# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Build stage
# Build stage
FROM python:3.10-slim-bookworm AS builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        g++ \
    && rm -rf /var/lib/apt/lists/*

# Download gRPC health probe
ENV GRPC_HEALTH_PROBE_VERSION=v0.4.18

RUN wget -qO /bin/grpc_health_probe \
    "https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64" \
    && chmod +x /bin/grpc_health_probe

WORKDIR /recommendationservice

COPY requirements.txt .

RUN pip install --no-cache-dir \
    --prefix=/install \
    -r requirements.txt

# Runtime stage
FROM python:3.10-slim-bookworm AS runtime

ENV PYTHONUNBUFFERED=1
ENV PORT=8080

WORKDIR /recommendationservice

COPY --from=builder /install/ /usr/local/
COPY --from=builder /bin/grpc_health_probe /bin/grpc_health_probe

COPY . .

EXPOSE 8080

# Change recommendation_server.py if your actual startup file has another name
CMD ["python", "recommendation_server.py"]
