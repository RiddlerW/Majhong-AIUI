<script def>
{
  "navigationBarTitleText": "拍照识别",
  "description": "拍照识别当前手牌",
  "schema": {
    "data": {
      "type": "object",
      "properties": {}
    }
  }
}
</script>
<script setup>
import wx from 'wx';

export default {
  data: {
    ruleName: '血战到底',
    isCapturing: false,
    statusText: '对准手牌后点击拍照'
  },
  onLoad() {
    var app = getApp();
    var ruleType = (app && app.globalData.ruleType) || wx.getStorageSync('ruleType') || 'xz';
    var ruleNames = { xz: '血战到底', xl: '血流成河', gb: '国标麻将' };
    this.setData({ ruleName: ruleNames[ruleType] || '血战到底' });
  },
  takePhoto() {
    if (this.data.isCapturing) return;
    this.setData({ isCapturing: true, statusText: '识别中...' });

    var self = this;
    var camera = wx.media.createCameraContext();

    camera.takePhoto({ quality: 'high' }).then(function(photo) {
      return self.recognizeImage(photo.data);
    }).then(function(result) {
      var app = getApp();
      if (app) {
        app.globalData.handTiles = result.handTiles || [];
        app.globalData.pengTiles = result.pengTiles || [];
        app.globalData.gangTiles = result.gangTiles || [];
      }
      wx.setStorageSync('lastRecognition', {
        handTiles: result.handTiles || [],
        pengTiles: result.pengTiles || [],
        gangTiles: result.gangTiles || [],
        timestamp: Date.now()
      });
      self.setData({ isCapturing: false, statusText: '识别完成' });
      wx.navigateTo({ url: '/pages/confirm/index' });
    }).catch(function(err) {
      console.error('识别失败:', err);
      self.setData({ isCapturing: false, statusText: '识别失败，请重试' });
    });
  },
  recognizeImage(imageData) {
    var app = getApp();
    var ruleType = (app && app.globalData.ruleType) || wx.getStorageSync('ruleType') || 'xz';
    var lastResult = wx.getStorageSync('lastRecognition') || null;

    var prompt = '请识别图片中的麻将牌，按以下JSON格式输出：\n' +
      '{"hand_tiles": ["一万","一万","三万",...], ' +
      '"peng_tiles": [["东风","东风","东风"]], ' +
      '"gang_tiles": [["五筒","五筒","五筒","五筒"]]}\n' +
      'hand_tiles为手牌，peng_tiles为碰出的牌组，gang_tiles为杠出的牌组。\n' +
      '如果无法区分碰/杠区域，将所有牌放入hand_tiles。';

    if (lastResult && lastResult.handTiles && lastResult.handTiles.length > 0) {
      var C = require('../../lib/mahjong-constants.js');
      var prevDesc = C.formatTilesForPrompt(lastResult);
      prompt += '\n\n上一轮识别结果为：' + prevDesc +
        '。当前图片应与上一轮相比变化有限，但请以当前图片实际内容为准。' +
        '如果发现当前图片与上一轮差异很大，以当前图片为准。';
    }

    var apiKey = wx.getStorageSync('minimaxApiKey') || '';
    if (!apiKey) {
      return Promise.resolve({
        handTiles: [],
        pengTiles: [],
        gangTiles: []
      });
    }

    return fetch('https://api.minimax.chat/v1/mcp/understand_image', {
      method: 'POST',
      headers: {
        'Authorization': 'Bearer ' + apiKey,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        image: self.arrayBufferToBase64(imageData),
        prompt: prompt
      })
    }).then(function(res) {
      return res.json();
    }).then(function(data) {
      return self.parseRecognitionResult(data, ruleType);
    });
  },
  arrayBufferToBase64(buffer) {
    var bytes = new Uint8Array(buffer);
    var binary = '';
    for (var i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
  },
  parseRecognitionResult(data, ruleType) {
    var C = require('../../lib/mahjong-constants.js');
    var result = { handTiles: [], pengTiles: [], gangTiles: [] };

    try {
      var parsed = typeof data === 'string' ? JSON.parse(data) : data;
      if (parsed.hand_tiles) {
        result.handTiles = parsed.hand_tiles.map(function(name) {
          return C.nameToIndex(name);
        }).filter(function(idx) { return idx >= 0; });
      }
      if (parsed.peng_tiles) {
        result.pengTiles = parsed.peng_tiles.map(function(group) {
          return group.map(function(name) { return C.nameToIndex(name); })
            .filter(function(idx) { return idx >= 0; });
        }).filter(function(group) { return group.length === 3; });
      }
      if (parsed.gang_tiles) {
        result.gangTiles = parsed.gang_tiles.map(function(group) {
          return group.map(function(name) { return C.nameToIndex(name); })
            .filter(function(idx) { return idx >= 0; });
        }).filter(function(group) { return group.length === 4; });
      }
    } catch (e) {
      console.error('解析识别结果失败:', e);
    }

    return result;
  },
  goBack() {
    wx.navigateBack();
  }
}
</script>
<page>
  <view class="container">
    <view class="header">
      <text class="rule-tag">{{ruleName}}</text>
    </view>
    <view class="camera-area">
      <text class="camera-hint">📷 相机取景</text>
    </view>
    <text class="status-text">{{statusText}}</text>
    <button class="capture-btn {{isCapturing ? 'disabled' : ''}}" bindtap="takePhoto">
      {{isCapturing ? '识别中...' : '拍照识别'}}
    </button>
  </view>
</page>
<style>
.container {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  background-color: #000;
  height: 100vh;
  box-sizing: border-box;
}
.header {
  width: 100%;
  margin-bottom: 16px;
}
.rule-tag {
  font-size: 14px;
  color: rgba(64, 255, 94, 0.6);
  background-color: rgba(64, 255, 94, 0.1);
  padding: 4px 12px;
  border-radius: 8px;
}
.camera-area {
  width: 100%;
  height: 200px;
  border-radius: 12px;
  border: 2px solid rgba(64, 255, 94, 0.3);
  background-color: rgba(64, 255, 94, 0.05);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}
.camera-hint {
  font-size: 18px;
  color: rgba(64, 255, 94, 0.4);
}
.status-text {
  font-size: 14px;
  color: rgba(64, 255, 94, 0.6);
  margin-bottom: 16px;
}
.capture-btn {
  width: 100%;
  height: 50px;
  border-radius: 12px;
  background-color: #40FF5E;
  color: #000;
  font-size: 18px;
  font-weight: bold;
  text-align: center;
  line-height: 50px;
}
.capture-btn.disabled {
  background-color: rgba(64, 255, 94, 0.3);
  color: rgba(0, 0, 0, 0.5);
}
</style>
