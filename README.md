# olmOCR RunPod Serverless Endpoint

This repository contains the configuration to deploy the [allenai/olmOCR-2-7B-1025-FP8](https://huggingface.co/allenai/olmOCR-2-7B-1025-FP8) multimodal vision-language model as a serverless API endpoint on RunPod.

This setup is highly optimized to use **RunPod's Network Cached Models** and runs efficiently on 24GB Ampere-generation GPUs (RTX 3090, RTX 4090, L4, A10G) using `vLLM` with FP8 quantization. It also includes an automatic safety downscaler to prevent OOM (Out Of Memory) crashes from excessively large image files.

## 🚀 Repository Contents
* `Dockerfile`: Uses the lightweight official `alleninstituteforai/olmocr:latest` image and configures the environment to load the model from RunPod's network cache.
* `handler.py`: The Python script that decodes base64 images, resizes them safely, formats the prompt for the Qwen2.5-VL architecture, and executes inference via vLLM.

## 🛠️ Deployment Instructions

To deploy this API, you will connect this GitHub repository directly to RunPod Serverless.

1. **Push to GitHub:** Ensure this `Dockerfile` and `handler.py` are pushed to the `main` branch of your repository.
2. **Create Endpoint:** Go to the [RunPod Serverless Console](https://www.runpod.io/console/serverless) and click **New Endpoint**.
3. **Select GitHub Integration:** Choose your repository from the Git source dropdown.
4. **Configure the Worker Environment:**
    * **GPU:** Select a 24GB VRAM GPU (e.g., RTX 3090, RTX 4090, L4, or A10G).
    * **Active Workers:** `0` (Scales to zero to save costs)
    * **Max Workers:** `1` (Ensures jobs queue up instead of crashing the single worker).
    * **Container Disk:** Set to `20 GB`.
5. **Configure the Cached Model (Crucial!):**
    * Scroll down to the **Model** section.
    * Enter `allenai/olmOCR-2-7B-1025-FP8` in the Hugging Face ID field.
    * *Note: This ensures the 30GB model is mounted instantly from RunPod's local network, eliminating 10-minute cold start download times.*
6. **Deploy:** Click deploy. RunPod will build your container and start the endpoint.

## 💻 API Usage

Your API expects a JSON payload with a base64 encoded image string inside the `input` object. 

### Example: Calling the Endpoint from a Python Backend
If you are integrating this API into a Python-based backend service (such as a Flask or FastAPI app), you can easily call the endpoint using the `requests` library:

```python
import os
import base64
import requests

RUNPOD_API_KEY = "your_runpod_api_key"
ENDPOINT_ID = "your_endpoint_id"

def get_text_from_image(image_path):
    # 1. Read and encode the local image to base64
    with open(image_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode('utf-8')

    # 2. Construct the payload
    payload = {
        "input": {
            "image": encoded_string,
            "temperature": 0.1,  # Keep low for OCR accuracy
            "max_tokens": 2048
        }
    }

    # 3. Call the RunPod Serverless API (Synchronous request)
    url = f"[https://api.runpod.ai/v2/](https://api.runpod.ai/v2/){ENDPOINT_ID}/runsync"
    headers = {
        "Authorization": f"Bearer {RUNPOD_API_KEY}",
        "Content-Type": "application/json"
    }

    try:
        response = requests.post(url, json=payload, headers=headers, timeout=120)
        response.raise_for_status()
        
        result = response.json()
        
        # Check if RunPod returned an error
        if "error" in result:
             return f"RunPod Error: {result['error']}"
             
        # Extract the actual text output
        return result.get("output", {}).get("text", "No text found.")
        
    except Exception as e:
        return f"Request failed: {str(e)}"

# Example usage:
if __name__ == "__main__":
    extracted_text = get_text_from_image("sample_invoice.jpg")
    print(extracted_text)