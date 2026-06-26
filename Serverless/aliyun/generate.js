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
  },
  goldplated: {
    prompt: '风格迁移应用，将此新中式鎏金水墨山水风格应用到原图，墨蓝深黑与鎏金金箔撞色主调，山体岩石如果有则布满鎏金烫金肌理纹路，流动乳白色云雾云海，通透雾霭虚实层次，水墨泼墨融合厚涂油画质感，鎏金描边勾勒轮廓，柔和日出漫射光影，轻奢国风，厚重笔触感，细腻肌理，8K超高清，高级低饱和柔雾色调，大气磅礴仙气空灵，中式红色篆刻印章点缀，无多余杂物',
    negativePrompt: '模糊，低分辨率，杂乱线条，人物，房屋建筑，卡通二次元，塑料扁平质感，暗沉脏色，刺眼强光，水印文字，变形元素，构图失衡，多余杂物，现代写实人像，色彩艳丽刺眼'
  }
};

exports.handler = async (req, resp, context) => {
  let body = {};
  
  try {
    if (req.method !== 'POST') {
      resp.setStatusCode(405);
      resp.setHeader('Content-Type', 'application/json');
      resp.send(JSON.stringify({ error: 'Method not allowed' }));
      return;
    }

    const rawBody = req.body || req.bodyBuffer?.toString() || '{}';
    body = typeof rawBody === 'string' ? JSON.parse(rawBody) : rawBody;

    const headers = req.headers || {};

    if (APP_SECRET && headers['x-app-secret'] !== APP_SECRET) {
      resp.setStatusCode(401);
      resp.setHeader('Content-Type', 'application/json');
      resp.send(JSON.stringify({ error: 'Unauthorized' }));
      return;
    }

    const { imageBase64, styleId } = body;

    if (!imageBase64 || !styleId) {
      resp.setStatusCode(400);
      resp.setHeader('Content-Type', 'application/json');
      resp.send(JSON.stringify({ error: 'Missing imageBase64 or styleId' }));
      return;
    }

    const style = STYLE_PRESETS[styleId];
    if (!style) {
      resp.setStatusCode(400);
      resp.setHeader('Content-Type', 'application/json');
      resp.send(JSON.stringify({ error: 'Invalid styleId' }));
      return;
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
      resp.setStatusCode(response.status);
      resp.setHeader('Content-Type', 'application/json');
      resp.send(JSON.stringify({
        error: data.error?.message || 'Generation failed',
        details: data
      }));
      return;
    }

    if (!data.data || !data.data[0]) {
      resp.setStatusCode(500);
      resp.setHeader('Content-Type', 'application/json');
      resp.send(JSON.stringify({ error: 'No image generated' }));
      return;
    }

    const generatedImage = data.data[0].b64_json;

    resp.setStatusCode(200);
    resp.setHeader('Content-Type', 'application/json');
    resp.send(JSON.stringify({
      success: true,
      imageBase64: generatedImage,
      style: styleId
    }));

  } catch (error) {
    console.error('Server error:', error);
    resp.setStatusCode(500);
    resp.setHeader('Content-Type', 'application/json');
    resp.send(JSON.stringify({ error: 'Internal server error' }));
  }
};
