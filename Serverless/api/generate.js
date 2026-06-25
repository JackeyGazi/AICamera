const fetch = require('node-fetch');

const ARK_API_KEY = process.env.ARK_API_KEY;
const ARK_MODEL = process.env.ARK_MODEL || 'doubao-seedream-4-0-250828';
const ARK_ENDPOINT = process.env.ARK_ENDPOINT || 'https://ark.cn-beijing.volces.com/api/v3/images/generations';
const APP_SECRET = process.env.APP_SECRET;

const STYLE_PRESETS = {
  ink: {
    prompt: '传统中国水墨画风格，留白写意，水墨晕染效果，黑白灰调，宣纸质感，意境悠远',
    negativePrompt: ''
  },
  ancient: {
    prompt: '古风中国风头像，古典雅致，汉服元素，东方韵味，柔美细腻，唯美画风，精致发饰',
    negativePrompt: ''
  },
  chibi: {
    prompt: 'Q版萌趣头像，chibi风格，大头小身体，可爱呆萌，圆润线条，色彩明亮，卡通风格',
    negativePrompt: ''
  },
  anime: {
    prompt: '日系动漫风格头像，二次元画风，精致细腻，柔和色彩，动漫人物，赛璐璐上色',
    negativePrompt: ''
  },
  doll3d: {
    prompt: '3D玩偶风格头像，Q版立体，皮克斯风格，可爱圆润，3D渲染，柔和光照，质感细腻',
    negativePrompt: ''
  },
  cyberpunk: {
    prompt: '赛博朋克风格写真，未来科技感，霓虹灯光，金属质感，蓝紫橙配色，机械元素，高对比度',
    negativePrompt: ''
  }
};

module.exports = async (req, res) => {
  try {
    if (req.method !== 'POST') {
      return res.status(405).json({ error: 'Method not allowed' });
    }

    if (APP_SECRET && req.headers['x-app-secret'] !== APP_SECRET) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const { imageBase64, styleId } = req.body;

    if (!imageBase64 || !styleId) {
      return res.status(400).json({ error: 'Missing imageBase64 or styleId' });
    }

    const style = STYLE_PRESETS[styleId];
    if (!style) {
      return res.status(400).json({ error: 'Invalid styleId' });
    }

    const imageData = imageBase64.startsWith('data:image')
      ? imageBase64
      : `data:image/jpeg;base64,${imageBase64}`;

    const requestBody = {
      model: ARK_MODEL,
      prompt: style.prompt,
      image: imageData,
      size: '1024x1024',
      response_format: 'b64_json'
    };

    const response = await fetch(ARK_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${ARK_API_KEY}`
      },
      body: JSON.stringify(requestBody)
    });

    const data = await response.json();

    if (!response.ok) {
      console.error('ARK API Error:', data);
      return res.status(response.status).json({
        error: data.error?.message || 'Generation failed',
        details: data
      });
    }

    if (!data.data || !data.data[0]) {
      return res.status(500).json({ error: 'No image generated' });
    }

    const generatedImage = data.data[0].b64_json;

    res.status(200).json({
      success: true,
      imageBase64: generatedImage,
      style: styleId
    });

  } catch (error) {
    console.error('Server error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};
