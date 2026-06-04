from flask import Flask, request, jsonify
from PIL import Image
from transformers import BlipProcessor, BlipForConditionalGeneration
from deep_translator import GoogleTranslator

app = Flask(__name__)

# ⚡ FAST MODEL (instead of large)
processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-base")
model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-base")

# 🌍 TRANSLATION
def translate_text(text, lang):
    try:
        print("Target language:", lang)

        if lang == "en":
            return text

        translated = GoogleTranslator(source='en', target=lang).translate(text)
        return translated if translated else text

    except Exception as e:
        print("Translation error:", e)
        return text


# 🚨 DANGER DETECTION
def detect_danger(caption):
    keywords = ["fire", "knife", "car", "bus", "truck", "weapon", "accident"]

    found = []
    for word in keywords:
        if word in caption.lower():
            found.append(word)

    return found


# ================= SINGLE FAST API =================
@app.route("/caption", methods=["POST"])
def caption():
    try:
        file = request.files["image"]
        lang = request.form.get("lang", "en")

        image = Image.open(file.stream).convert("RGB")

        inputs = processor(image, return_tensors="pt")

        # ⚡ FAST GENERATION
        output = model.generate(
            **inputs,
            max_length=20,
            num_beams=2
        )

        caption = processor.decode(output[0], skip_special_tokens=True)
        caption = caption.replace("describe the scene in detail", "").strip()

        # 🚨 DETECT (same API)
        danger = detect_danger(caption)

        # 🌍 TRANSLATE
        caption = translate_text(caption, lang)

        return jsonify({
            "caption": caption,
            "danger": danger
        })

    except Exception as e:
        return jsonify({"error": str(e)})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)