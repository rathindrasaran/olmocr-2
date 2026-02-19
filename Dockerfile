# Use the image with the model baked in
FROM alleninstituteforai/olmocr:v0.4.25-with-model

WORKDIR /
# Force offline mode so the container uses the baked-in model instantly instead of checking the internet
ENV HF_HUB_OFFLINE="1"

COPY requirements.txt /requirements.txt

RUN apt-get update
RUN apt-get install -y python3 python3-pip python-is-python3
RUN pip install -r requirements.txt

COPY handler.py /

CMD [ "python", "-u", "handler.py" ]
