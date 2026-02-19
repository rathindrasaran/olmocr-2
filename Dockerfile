# Use the lightweight base image (WITHOUT the 30GB model baked in)
FROM alleninstituteforai/olmocr:latest

# Point Hugging Face directly to RunPod's native serverless model cache volume
ENV HF_HOME="/runpod-volume/huggingface-cache/hub/"

# Force offline mode so the container never attempts a slow internet download
ENV HF_HUB_OFFLINE="1"

# Install the RunPod SDK
RUN pip install runpod

COPY handler.py /handler.py

CMD [ "python", "-u", "/handler.py" ]