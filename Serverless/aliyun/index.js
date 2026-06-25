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

function jsonResponse(statusCode, data) {
  return {
    statusCode: statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type, x-app-secret',
      'Access-Control-Allow-Methods': 'POST, OPTIONS'
    },
    body: JSON.stringify(data)
  };
}

function getBody(req) {
  if (!req.body) return {};
  if (typeof req.body === 'object') return req.body;
  try {
    return JSON.parse(req.body.toString());
  } catch (e) {
    return {};
  }
}

module.exports.handler = async (req, resp, context) => {
  try {
    const method = req.method || req.httpMethod || 'GET';
    const path = req.path || req.url || '/';
    const headers = req.headers || {};
    const isGenerate = path.includes('/generate');

    if (method === 'OPTIONS' || !isGenerate) {
      return jsonResponse(200, { status: 'ok', method, path });
    }

    if (method !== 'POST') {
      return jsonResponse(405, { error: 'Method not allowed' });
    }

    if (APP_SECRET && headers['x-app-secret'] !== APP_SECRET) {
      return jsonResponse(401, { error: 'Unauthorized' });
    }

    const body = getBody(req);
    const { imageBase64, styleId } = body;

    if (!imageBase64 || !styleId) {
      return jsonResponse(400, { error: 'Missing imageBase64 or styleId' });
    }

    const style = STYLE_PRESETS[styleId];
    if (!style) {
      return jsonResponse(400, { error: 'Invalid styleId' });
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
      body: JSON.stringify(requestBody),
      timeout: 120000
    });

    const data = await response.json();

    if (!response.ok) {
      console.error('ARK API Error:', JSON.stringify(data));
      return jsonResponse(response.status, {
        error: data.error?.message || 'Generation failed',
        details: data
      });
    }

    if (!data.data || !data.data[0]) {
      return jsonResponse(500, { error: 'No image generated' });
    }

    const generatedImage = data.data[0].b64_json;

    return jsonResponse(200, {
      success: true,
      imageBase64: generatedImage,
      style: styleId
    });

  } catch (error) {
    console.error('Server error:', error);
    return jsonResponse(500, { error: 'Internal server error' });
  }
};
