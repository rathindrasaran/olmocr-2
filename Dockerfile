# Use the image with the model baked in
FROM alleninstituteforai/olmocr:v0.4.25-with-model

# Force offline mode so the container uses the baked-in model instantly instead of checking the internet
ENV HF_HUB_OFFLINE="1"

# Install the RunPod SDK
RUN pip install runpod

COPY handler.py /handler.py

CMD [ "python", "-u", "/handler.py" ]