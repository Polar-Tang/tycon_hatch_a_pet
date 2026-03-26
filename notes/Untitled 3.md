

---
```
latents.shape  
```

```output
torch.Size([1, 4, 64, 64])
```


---

Cool 64×64 is expected. The model will transform this latent representation (pure noise) into a `512 × 512` image later on.

Next, we initialize the scheduler with our chosen `num_inference_steps`. This will compute the `sigmas` and exact time step values to be used during the denoising process.

---
```
scheduler.set_timesteps(num_inference_steps)  
```

---

The K-LMS scheduler needs to multiply the `latents` by its `sigma` values. Let's do this here

---
```
latents = latents * scheduler.init_noise_sigma  
```


---

We are ready to write the denoising loop.

---
```
from tqdm.auto import tqdm  
from torch import autocast  
  
for t in tqdm(scheduler.timesteps):  
  # expand the latents if we are doing classifier-free guidance to avoid doing two forward passes.  
  latent_model_input = torch.cat([latents] * 2)  
  
  latent_model_input = scheduler.scale_model_input(latent_model_input, t)  
  
  # predict the noise residual  
  with torch.no_grad():  
    noise_pred = unet(latent_model_input, t, encoder_hidden_states=text_embeddings).sample  
  
  # perform guidance  
  noise_pred_uncond, noise_pred_text = noise_pred.chunk(2)  
  noise_pred = noise_pred_uncond + guidance_scale * (noise_pred_text - noise_pred_uncond)  
  
  # compute the previous noisy sample x_t -> x_t-1  
  latents = scheduler.step(noise_pred, t, latents).prev_sample  
```

---

We now use the `vae` to decode the generated `latents` back into the image.

---
```
# scale and decode the image latents with vae  
latents = 1 / 0.18215 * latents  
  
with torch.no_grad():  
  image = vae.decode(latents).sample  
```

---

And finally, let's convert the image to PIL so we can display or save it.

---

---

Now you have all the pieces to build your own pipelines or use diffusers components as you like 🔥.

```
from transformers import CLIPTextModel, CLIPTokenizer

from diffusers import AutoencoderKL, UNet2DConditionModel, PNDMScheduler

  

# 1. Load the autoencoder model which will be used to decode the latents into image space.

vae = AutoencoderKL.from_pretrained("CompVis/stable-diffusion-v1-4", subfolder="vae")

  

# 2. Load the tokenizer and text encoder to tokenize and encode the text.

tokenizer = CLIPTokenizer.from_pretrained("openai/clip-vit-large-patch14")

text_encoder = CLIPTextModel.from_pretrained("openai/clip-vit-large-patch14")

  

# 3. The UNet model for generating the latents.

unet = UNet2DConditionModel.from_pretrained("CompVis/stable-diffusion-v1-4", subfolder="unet")
from diffusers import LMSDiscreteScheduler

  

scheduler = LMSDiscreteScheduler.from_pretrained("CompVis/stable-diffusion-v1-4", subfolder="scheduler")
from diffusers import LMSDiscreteScheduler

  

scheduler = LMSDiscreteScheduler.from_pretrained("CompVis/stable-diffusion-v1-4", subfolder="scheduler")
prompt = ["a dragon flying over a city"]

  

height = 512 # default height of Stable Diffusion

width = 512 # default width of Stable Diffusion

  

num_inference_steps = 100 # Number of denoising steps

  

guidance_scale = 7.5 # Scale for classifier-free guidance

  

generator = torch.manual_seed(32) # Seed generator to create the inital latent noise

  

batch_size = 1



``