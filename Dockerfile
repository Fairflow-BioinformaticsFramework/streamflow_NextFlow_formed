FROM docker:dind

RUN apk add --no-cache \
    bash \
    curl \
    python3 \
    py3-pip \
    openjdk17-jre \
    git

RUN curl -fsSL https://get.nextflow.io | bash && \
    mv nextflow /usr/local/bin/ && \
    chmod +x /usr/local/bin/nextflow

RUN pip install --break-system-packages \
    streamflow \
    fastapi \
    uvicorn \
    python-multipart

# Patch Streamflow's Docker connector:
# Fix 1: take only last line of docker run stdout as container ID
#         (strips Docker deprecation warnings that corrupt the ID)
# Fix 2: return [] instead of crashing when docker inspect returns empty JSON
RUN sed -i \
    's/self\.containerIds\.append(stdout\.decode()\.strip())/self.containerIds.append(stdout.decode().strip().splitlines()[-1].strip())/' \
    /usr/lib/python3.12/site-packages/streamflow/deployment/connector/container.py && \
    sed -i \
    's/return json\.loads(stdout\.decode()\.strip())/raw = stdout.decode().strip(); return json.loads(raw) if raw and raw.startswith("[") else []/' \
    /usr/lib/python3.12/site-packages/streamflow/deployment/connector/container.py

COPY app/ /app/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8082
ENTRYPOINT ["/entrypoint.sh"]
