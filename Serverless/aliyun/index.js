const fetch = require('node-fetch');

const ARK_API_KEY = process.env.ARK_API_KEY;
const ARK_MODEL = process.env.ARK_MODEL || 'doubao-seedream-4-0-250828';
const ARK_ENDPOINT = process.env.ARK_ENDPOINT || 'https://ark.cn-beijing.volces.com/api/v3/images/generations';
const APP_SECRET = process.env.APP_SECRET;

const STYLE_PRESETS = {
  ink: { prompt: '传统中国水墨画风格，留白写意，水墨晕染效果，黑白灰调，宣纸质感，意境悠远' },
  ancient: { prompt: '古风中国风头像，古典雅致，汉服元素，东方韵味，柔美细腻，唯美画风，精致发饰' },
  chibi: { prompt: 'Q版萌趣头像，chibi风格，大头小身体，可爱呆萌，圆润线条，色彩明亮，卡通风格' },
  anime: { prompt: '日系动漫风格头像，二次元画风，精致细腻，柔和色彩，动漫人物，赛璐璐上色' },
  doll3d: { prompt: '3D玩偶风格头像，Q版立体，皮克斯风格，可爱圆润，3D渲染，柔和光照，质感细腻' },
  cyberpunk: { prompt: '赛博朋克风格写真，未来科技感，霓虹灯光，金属质感，蓝紫橙配色，机械元素，高对比度' },
  goldplated: { prompt: '风格迁移应用，将此新中式鎏金水墨山水风格应用到原图，墨蓝深黑与鎏金金箔撞色主调，山体岩石布满鎏金烫金肌理纹路，流动乳白色云雾云海，通透雾霭虚实层次，水墨泼墨融合厚涂油画质感，鎏金描边勾勒轮廓，柔和日出漫射光影，轻奢国风，厚重笔触感，细腻肌理，8K超高清，高级低饱和柔雾色调，大气磅礴仙气空灵，中式红色篆刻印章点缀，无多余杂物' }
};

function parseEvent(event) {
  if (Buffer.isBuffer(event)) {
    event = event.toString('utf8');
  }
  if (typeof event === 'string') {
    try {
      event = JSON.parse(event);
    } catch (e) {
      console.error('Parse event JSON error:', e.message);
      return {};
    }
  }
  return event || {};
}

function getMethod(evt) {
  return evt.httpMethod
    || evt.method
    || (evt.requestContext && evt.requestContext.http && evt.requestContext.http.method)
    || (evt.requestContext && evt.requestContext.method)
    || 'GET';
}

function getPath(evt) {
  return evt.path
    || evt.rawPath
    || (evt.requestContext && evt.requestContext.http && evt.requestContext.http.path)
    || '/';
}

function parseBody(evt) {
  let body = evt.body;
  if (!body) return {};
  if (evt.isBase64Encoded) {
    try {
      body = Buffer.from(body, 'base64').toString('utf8');
    } catch (e) {
      return {};
    }
  }
  try {
    return typeof body === 'string' ? JSON.parse(body) : body;
  } catch (e) {
    console.error('Parse body error:', e.message);
    return {};
  }
}

function jsonResponse(statusCode, data) {
  return {
    statusCode: statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type, x-app-secret',
      'Access-Control-Allow-Methods': 'POST, OPTIONS'
    },
    body: JSON.stringify(data),
    isBase64Encoded: false
  };
}

module.exports.handler = async function(event, context, callback) {
  try {
    const evt = parseEvent(event);
    const method = getMethod(evt);
    const path = getPath(evt);
    const headers = evt.headers || {};

    if (method === 'OPTIONS') {
      return jsonResponse(200, {});
    }

    if (method === 'GET') {
      return jsonResponse(200, { status: 'ok', method, path });
    }

    if (method !== 'POST') {
      return jsonResponse(405, { error: 'Method not allowed', method });
    }

    if (APP_SECRET && headers['x-app-secret'] !== APP_SECRET && headers['X-App-Secret'] !== APP_SECRET) {
      return jsonResponse(401, { error: 'Unauthorized' });
    }

    const body = parseBody(evt);
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
      size: '2K',
      response_format: 'b64_json',
      watermark: false
    };

    console.log('Calling ARK API, model:', ARK_MODEL, 'style:', styleId);

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
      return jsonResponse(500, { error: 'No image generated', data });
    }

    const generatedImage = data.data[0].b64_json;

    return jsonResponse(200, {
      success: true,
      imageBase64: generatedImage,
      style: styleId
    });

  } catch (error) {
    console.error('Server error:', error);
    return jsonResponse(500, { error: 'Internal server error', message: error.message });
  }
};
