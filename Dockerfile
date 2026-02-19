# Use the image with the model baked in
FROM alleninstituteforai/olmocr:v0.4.25-with-model

WORKDIR /
# Force offline mode so the container uses the baked-in model instantly instead of checking the internet
ENV HF_HUB_OFFLINE="1"

COPY requirements.txt /requirements.txt

# We rely on the base image's Python environment and only install your extra RunPod requirements
RUN pip install -r requirements.txt

COPY handler.py /

# FIX: Clear any inherited entrypoint from the base image
ENTRYPOINT []

CMD [ "python", "-u", "handler.py" ]
